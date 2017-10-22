//
//  AlbumViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"
#import "ASIHTTPRequestDelegate.h"
#import "NIProcessorHTTPRequest.h"
#import "CustomCollectionView.h"
#import <MessageUI/MessageUI.h>

@class MainViewController;

@interface AlbumViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	MainViewController __weak *mainViewController;

	UITabBarItem *currentItem;

	SubRedditItem *currentSubReddit;
	SubRedditItem *subReddit;
	
	BOOL shouldReleaseCaches;
	BOOL bFavorites;
	BOOL bMOARLoading;
	NSMutableArray *currentPhotosArray;
	BOOL initialized;
}

@property (nonatomic, strong) SubRedditItem *subReddit;
@property (nonatomic) BOOL bFavorites;

+ (instancetype)viewControllerFromStoryboard;

- (void)onSelectPhoto:(PhotoItem *)photo;

@end
