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

	CustomCollectionView *contentCollectionView;
	IBOutlet UIView *footerView;
	IBOutlet UIButton *moarButton;
	IBOutlet UIActivityIndicatorView *moarWaitingView;
	IBOutlet UITabBar *tabBar;
	IBOutlet UITabBarItem *hotItem;
	IBOutlet UITabBarItem *newItem;
	IBOutlet UITabBarItem *controversialItem;
	IBOutlet UITabBarItem *topItem;
	UITabBarItem *currentItem;
	IBOutlet UISegmentedControl *showTypeSegmentedControl;

	SubRedditItem *currentSubReddit;
	SubRedditItem *subReddit;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	NIImageMemoryCache *thumbnailImageCache;
	
	BOOL shouldReleaseCaches;
	
	BOOL bFavorites;
	
	BOOL bMOARLoading;

	NSMutableArray *currentPhotosArray;

	BOOL initialized;
}

@property (nonatomic, weak) MainViewController *mainViewController;
@property (nonatomic, strong) SubRedditItem *subReddit;
@property (nonatomic) BOOL bFavorites;

- (IBAction)onMOARButton:(id)sender;
- (IBAction)onShowType:(id)sender;
- (void)onSelectPhoto:(PhotoItem *)photo;

@end
