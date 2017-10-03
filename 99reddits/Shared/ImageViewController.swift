//
//  PhotoViewController.swift
//  99reddits
//
//  Created by Pietro Rea on 10/2/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    fileprivate let imageURL: URL
    fileprivate let imageView = UIImageView()
    fileprivate let scrollView = UIScrollView()

    var index: Int?

    init(URL: URL) {
        self.imageURL = URL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        scrollView.frame = view.bounds
        scrollView.contentSize = self.imageView.frame.size
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        scrollView.isUserInteractionEnabled = true
        scrollView.delegate = self

        view.addSubview(self.scrollView)
        scrollView.addSubview(self.imageView)

        ImageLoader.load(urlString: imageURL.absoluteString, success: { [weak self] (image) in
            self?.imageView.image = image
        }) { (error) in
            //TODO
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        imageView.frame = view.bounds

        scrollView.contentSize = imageView.frame.size
        scrollView.contentOffset = .zero
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scrollView.contentSize = view.bounds.size
    }
}

extension ImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
