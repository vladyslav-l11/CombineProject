//
//  ViewController.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit

typealias PickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension MainVC: Makeable {
    static func make() -> MainVC {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainVC") { coder in
            MainVC(coder: coder)
        }
    }
}

final class MainVC: BaseVC, ViewModelContainer {
    var viewModel: MainVM?
    
    init?(viewModel: MainVM, coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        //getUsers(params: UserParams(results: 10))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openGallery()
    }
    
    func bind() {
        viewModel?.$users
            .compactMap { $0 }
            .sink {
                $0.forEach { user in
                    print("\(user.name.first) \(user.name.last)")
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$uploadResult
            .compactMap { $0 }
            .sink {
                print("Uploaded!!!")
            }
            .store(in: &subscriptions)
        
        viewModel?.$error
            .compactMap { $0 }
            .sink {
                print($0.localizedDescription)
            }
            .store(in: &subscriptions)
    }
    
    private func openGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.mediaTypes = ["public.image"]
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func getUsers(params: UserParams) {
        viewModel?.getUsers(params: params)
    }
    
    private func upload(params: UploadFileParams) {
        viewModel?.upload(params: params)
    }
}

// MARK: - PickerDelegate
extension MainVC: PickerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 100)else { return }
        let imageUrl = info[.imageURL] as? URL
        if let imageUrl = imageUrl, imageUrl.pathExtension != "jpeg" && imageUrl.pathExtension != "png" {
            dismiss(animated: true)
            return
        }
        upload(params: UploadFileParams(data: data,
                                        name: "image/\(imageUrl?.pathExtension ?? "jpeg")",
                                        mimeType: imageUrl?.pathExtension ?? "jpeg",
                                        fileExtension: imageUrl?.deletingPathExtension().lastPathComponent ?? image.description))
        dismiss(animated: true)
    }
}
