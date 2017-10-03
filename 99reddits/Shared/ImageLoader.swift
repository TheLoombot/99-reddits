//
//  ImageLoader.swift
//  99reddits
//
//  Created by Pietro Rea on 9/30/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit
import Nuke

typealias ImageLoaderSuccessHandler = ((UIImage) -> Void)
typealias ImageLoaderErrorHandler = ((Error) -> Void)

//Objective-C compatible wrapper around Nuke
class ImageLoader: NSObject {
  static func load(urlString: String, into imageView: UIImageView) {
    guard let url = URL(string: urlString) else {
      return
    }

    Nuke.loadImage(with: url, into: imageView)
  }

  static func load(urlString: String, success: @escaping ImageLoaderSuccessHandler, failure: @escaping ImageLoaderErrorHandler) {

    guard let url = URL(string: urlString) else {
      return
    }

    let request = Request(url: url)
    Manager.shared.loadImage(with: request) { (result) in
      switch result {
      case .success(let image):
        success(image)
      case .failure(let error):
        failure(error)
      }
    }
  }
}
