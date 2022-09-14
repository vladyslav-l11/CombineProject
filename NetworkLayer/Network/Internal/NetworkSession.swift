//
//  NetworkSession.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Foundation

class NetworkSession: NSObject {
    
    private enum PerformType {
        case data(DataRequest)
        case upload(UploadRequest)
        case download(DownloadRequest)
    }
    
    var session: URLSession?
    var startRequestsImmediately: Bool
    var requests: [Request] = []
    private let fileManager: FileManager
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default,
         startRequestsImmediately: Bool = true,
         fileManager: FileManager = .default) {
        self.startRequestsImmediately = startRequestsImmediately
        self.fileManager = fileManager
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    deinit {
        requests = []
        session?.invalidateAndCancel()
    }
    
    func upload(multipartFormData: MultipartFormData,
                with request: URLRequest,
                fileManager: FileManager = .default) -> UploadRequest {
        let request = UploadRequest(urlRequest: request,
                                    multipartFormData: multipartFormData,
                                    fileManager: fileManager)
        perform(with: .upload(request))
        return request
    }
    
    func request(_ urlRequest: URLRequest) -> DataRequest {
        let request = DataRequest(urlRequest: urlRequest)
        perform(with: .data(request))
        return request
    }
    
    func download(_ urlRequest: URLRequest,
                  to destination: DownloadDestination?) -> DownloadRequest {
        
        let request = DownloadRequest(urlRequest: urlRequest,
                                      destination: destination)
        perform(with: .download(request))
        return request
    }
    
    private func perform(with performType: PerformType) {
        switch performType {
        case .data(let dataRequest):
            performRequest(with: dataRequest)
        case .upload(let uploadRequest):
            performUpload(with: uploadRequest)
        case .download(let downloadRequest):
            performDownload(with: downloadRequest)
        }
    }
    
    private func performRequest(with dataRequest: DataRequest) {
        guard let urlRequest = dataRequest.urlRequest,
              let publisher = session?.dataTaskPublisher(for: urlRequest) else {
                  assertionFailure("URL Request or session is not found.")
                  return
        }
        
        requests.append(dataRequest)
        dataRequest.didCreatePublisher(publisher)
    }
    
    private func performUpload(with uploadRequest: UploadRequest) {
        guard let urlRequest = try? uploadRequest.getUrlRequest(),
              let publisher = session?.dataTaskPublisher(for: urlRequest) else {
                  assertionFailure("URL Request or session is not found.")
                  return
        }
        
        requests.append(uploadRequest)
        uploadRequest.didCreatePublisher(publisher)
    }
    
    private func performDownload(with downloadRequest: DownloadRequest) {
        guard let publisher = session?.downloadTaskPublisher(for: downloadRequest) else {
            assertionFailure("Session is not found.")
            return
        }
        
        requests.append(downloadRequest)
        downloadRequest.didCreatePublisher(publisher)
    }
    
    private func request<R: Request>(for task: URLSessionTask, as type: R.Type) -> R? {
        requests.first(where: { $0 is R && $0.urlRequest == task.originalRequest }) as? R
    }
}

// MARK: - URLSessionDownloadDelegate
extension NetworkSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {}
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                    expectedTotalBytes: Int64) {
        guard let downloadRequest = request(for: downloadTask, as: DownloadRequest.self) else {
            assertionFailure("downloadTask did not find DownloadRequest.")
            return
        }

        downloadRequest.updateDownloadProgress(bytesWritten: fileOffset,
                                               totalBytesExpectedToWrite: expectedTotalBytes)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let downloadRequest = request(for: downloadTask, as: DownloadRequest.self) else {
            assertionFailure("downloadTask did not find DownloadRequest.")
            return
        }

        downloadRequest.updateDownloadProgress(bytesWritten: bytesWritten,
                                               totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: - URLSessionTaskDelegate
extension NetworkSession: URLSessionDataDelegate {
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let uploadRequest = request(for: task, as: UploadRequest.self)
        uploadRequest?.updateUploadProgress(totalBytesSent: totalBytesSent,
                                           totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
}
