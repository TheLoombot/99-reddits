//
//  PhotoNavigationController.m
//  99reddits
//
//  Created by Pietro Rea on 10/29/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import "PhotoNavigationController.h"

@interface PhotoNavigationController ()

@end

@implementation PhotoNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    [self attachCloseButton:rootViewController];
    return [super initWithRootViewController:rootViewController];
}

- (void)attachCloseButton:(UIViewController *)rootViewController {

    if (rootViewController.navigationItem.leftBarButtonItem) {
        return;
    }

    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissNavigationController)];
    rootViewController.navigationItem.leftBarButtonItem = doneBarButtonItem;
}

- (void)dismissNavigationController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
