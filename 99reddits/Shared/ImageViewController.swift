//
//  PhotoViewController.swift
//  99reddits
//
//  Created by Pietro Rea on 10/2/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit

protocol ImageViewControllerDelegate: class {
    func didReceiveSingleTap(viewController: ImageViewController)
}

class ImageViewController: UIViewController {

    static let ImageViewControllerZoomedInScale: CGFloat = 2.0

    fileprivate let imageURL: URL
    fileprivate let imageView = UIImageView()
    fileprivate let scrollView = UIScrollView()

    weak var delegate: ImageViewControllerDelegate?

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
        navigationController?.navigationBar.isTranslucent = true

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        scrollView.frame = view.bounds
        scrollView.contentSize = self.imageView.frame.size
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.isUserInteractionEnabled = true
        scrollView.delegate = self

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }

        view.addSubview(self.scrollView)
        scrollView.addSubview(self.imageView)

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)

        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)

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

    func singleTap() {
        delegate?.didReceiveSingleTap(viewController: self)
    }

    func doubleTap() {
        guard scrollView.zoomScale < ImageViewController.ImageViewControllerZoomedInScale else {
            scrollView.setZoomScale(1, animated: true)
            return
        }

        scrollView.setZoomScale(ImageViewController.ImageViewControllerZoomedInScale, animated: true)
    }
}


extension ImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
