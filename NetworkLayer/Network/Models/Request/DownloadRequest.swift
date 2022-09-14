//
//  DownloadRequest.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Combine

final class DownloadRequest: Request, Publishable {
    let destination: DownloadDestination?
    let downloadProgress = Progress(totalUnitCount: 0)
    var downloadProgressCallback: Command<Progress>?
    var publisher: URLSession.DownloadTaskPublisher?
    var cancellable: AnyCancellable?
    
    init(urlRequest: URLRequest, destination: DownloadDestination?) {
        self.destination = destination
        super.init(urlRequest: urlRequest)
    }
    
    func downloadProgress(queue: DispatchQueue = .main, closure: @escaping ProgressHandler) -> Self {
        downloadProgressCallback = Command { progress in
            closure(progress)
        }
        return self
    }
    
    func updateDownloadProgress(bytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount += bytesWritten

        downloadProgressCallback?.perform(value: downloadProgress)
    }
    
    func didCreatePublisher(_ publisher: URLSession.DownloadTaskPublisher) {
        self.publisher = publisher
    }
    
    @discardableResult
    func resume() -> Self {
        cancellable = publisher?
            .mapError({ urlError in
                NetworkError(urlError)
            })
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    self?.cancel()
                    return
                }
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    return
                }
            },
                  receiveValue: { [weak self] (data, urlResponse) in
                guard let self = self, let httpResponse = urlResponse as? HTTPURLResponse else {
                    self?.cancel()
                    return
                }
                self.data = data
                self.responseCallback?.perform(value: httpResponse)
            })
        return self
    }
}

extension DownloadRequest {
    @discardableResult
    func responseData(completionHandler: @escaping (AsyncDownloadResponse<Data>) -> Void) -> Self {
        responseCallback = Command { [weak self] urlResponse in
            guard let self = self else { return }
            let result = Result { () -> Data in
                guard let data = self.data else {
                    throw NetworkError.missingData
                }
                
                if let error = self.error {
                    throw error
                }
                
                return data
            }.mapError {
                NetworkError($0)
            }
            
            let response = DownloadResponse(urlRequest: self.urlRequest,
                                            response: urlResponse,
                                            destination: self.destination,
                                            result: result)
            completionHandler(response)
        }
        return self
    }
}
