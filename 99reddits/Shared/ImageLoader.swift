//
//  ImageLoader.swift
//  99reddits
//
//  Created by Pietro Rea on 9/30/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit
import Nuke
import Alamofire

typealias ImageLoaderSuccessHandler = ((UIImage) -> Void)
typealias ImageLoaderDataSuccessHandler = ((Data) -> Void)
typealias ImageLoaderErrorHandler = ((Error) -> Void)

class ImageLoaderCancelationToken: NSObject {
    fileprivate let tokenSource: CancellationTokenSource

    init(tokenSource: CancellationTokenSource) {
        self.tokenSource = tokenSource
    }

    func cancel() {
        tokenSource.cancel()
    }
}

//Objective-C compatible wrapper around Nuke
class ImageLoader: NSObject {

    static let errorDomain = "ImageLoaderErrorDomain"
    static let malformedURLErrorCode = 100

    static func load(urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            return
        }

        Nuke.loadImage(with: url, into: imageView)
    }

    @discardableResult static func loadImage(withURL url: URL, success: @escaping ImageLoaderSuccessHandler, failure: @escaping ImageLoaderErrorHandler) -> ImageLoaderCancelationToken {

        let cts = CancellationTokenSource()
        let cancelationToken = ImageLoaderCancelationToken(tokenSource: cts)
        
        let request = Request(url: url)

        Manager.shared.loadImage(with: request, token: cts.token) { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    success(image)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }

        return cancelationToken
    }

    @discardableResult static func loadGif(withURL url: URL, success: @escaping ImageLoaderDataSuccessHandler, failure: @escaping ImageLoaderErrorHandler) -> Void {


        Alamofire.request(url).validate().responseData { response in
            switch response.result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure(error)
            }
        }
    }
}
