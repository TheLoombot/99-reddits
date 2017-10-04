//
//  PhotoPageViewController.swift
//  99reddits
//
//  Created by Pietro Rea on 10/2/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit

class PhotoPageViewController: UIViewController {

    var subredditItem: SubRedditItem? = nil
    var pageViewController: UIPageViewController? = nil

    var imageURLs: [URL] {
        guard let subredditItem = self.subredditItem,
            let photosArray = subredditItem.photosArray as? [PhotoItem] else {
                return []
        }

        return photosArray.flatMap({ (photoItem) -> URL? in
            guard let urlString =  photoItem.urlString,
                let url = URL(string: urlString) else {
                    return nil
            }

            return url
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = UIColor.blue
        pageViewController.dataSource = self
        pageViewController.delegate = self
        self.pageViewController = pageViewController

        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.view.matchParentSize()
        self.pageViewController?.didMove(toParentViewController: self)
    }

    func populate(with subreddit: SubRedditItem, at index: Int) {
        self.subredditItem = subreddit

        guard let imageViewController = self.photoViewController(for: 0) else {
            return
        }

        imageViewController.view.backgroundColor = UIColor.red
        imageViewController.view.frame = view.bounds
        self.pageViewController?.setViewControllers([imageViewController], direction: .forward, animated: false, completion: nil)
    }

    func photoViewController(for index: Int) -> UIViewController? {
        guard index >= 0,
            index < imageURLs.count - 1 else {
                return nil
        }

        let imageURL = imageURLs[index]
        let photoViewController = ImageViewController(URL: imageURL)
        photoViewController.index = index
        photoViewController.delegate = self

        return photoViewController
    }
}


extension PhotoPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let photoViewController = viewController as? ImageViewController,
            let photoIdx = photoViewController.index else {
                return nil
        }

        return self.photoViewController(for: photoIdx + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let photoViewController = viewController as? ImageViewController,
            let photoIdx = photoViewController.index else {
                return nil
        }

        return self.photoViewController(for: photoIdx - 1)
    }
}

extension PhotoPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //Add logging
    }
}


extension PhotoPageViewController: ImageViewControllerDelegate {
    func didReceiveSingleTap(viewController: ImageViewController) {
        guard let navController = navigationController,
            let isNavBarHidden = navigationController?.isNavigationBarHidden else {
                return
        }

        navController.setNavigationBarHidden(!isNavBarHidden, animated: true)
    }


}
