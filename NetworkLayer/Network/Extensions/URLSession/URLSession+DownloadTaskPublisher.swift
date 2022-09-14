//
//  URLSession+DownloadTaskPublisher.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 14.09.2022.
//

import Combine

// MARK: - Publisher
extension URLSession {
    func downloadTaskPublisher(for request: DownloadRequest,
                               with fileManager: FileManager = .default) -> URLSession.DownloadTaskPublisher {
        .init(request: request, session: self, fileManager: fileManager)
    }

    struct DownloadTaskPublisher: Publisher {
        typealias Output = (data: Data, response: URLResponse)
        typealias Failure = URLError

        private let request: DownloadRequest
        private let session: URLSession
        private let fileManager: FileManager

        init(request: DownloadRequest, session: URLSession, fileManager: FileManager) {
            self.request = request
            self.session = session
            self.fileManager = fileManager
        }

        func receive<S>(subscriber: S) where S: Subscriber,
            DownloadTaskPublisher.Failure == S.Failure,
            DownloadTaskPublisher.Output == S.Input
        {
            let subscription = DownloadTaskSubscription(subscriber: subscriber,
                                                        session: session,
                                                        request: request,
                                                        fileManager: fileManager)
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription
extension URLSession {

    final private class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
        SubscriberType.Input == (data: Data, response: URLResponse),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession?
        private var request: DownloadRequest
        private var task: URLSessionDownloadTask?
        private let fileManager: FileManager

        init(subscriber: SubscriberType,
             session: URLSession,
             request: DownloadRequest,
             fileManager: FileManager) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
            self.fileManager = fileManager
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else { return }
            guard let urlRequest = request.urlRequest else {
                subscriber?.receive(completion: .failure(URLError(.badURL)))
                return
            }
            
            task = session?.downloadTask(with: urlRequest) { [weak self] url, response, error in
                guard let self = self else {
                    self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                    return
                }
                if let error = error as? URLError {
                    self.subscriber?.receive(completion: .failure(error))
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    self.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
                    return
                }
                guard let url = url, let destination = self.request.destination else {
                    self.subscriber?.receive(completion: .failure(URLError(.badURL)))
                    return
                }
                let (location, options) = destination(url, response)
                
                do {
                    if options.contains(.removePreviousFile),
                       self.fileManager.fileExists(atPath: location.path) {
                        try self.fileManager.removeItem(at: location)
                    }

                    if options.contains(.createIntermediateDirectories) {
                        let directory = location.deletingLastPathComponent()
                        try self.fileManager.createDirectory(at: directory,
                                                             withIntermediateDirectories: true)
                    }

                    try self.fileManager.moveItem(at: url, to: location)
                    
                    let data = try Data(contentsOf: location)
                    _ = self.subscriber?.receive((data: data, response: response))
                    self.subscriber?.receive(completion: .finished)
                }
                catch {
                    self.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                }
            }
            task?.resume()
        }

        func cancel() {
            task?.cancel()
        }
    }
}

