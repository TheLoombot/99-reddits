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
#import "CustomTableView.h"

@class RedditsAppDelegate;
@class MainViewController;

@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate> {
	RedditsAppDelegate *appDelegate;
	MainViewController *mainViewController;
	
	IBOutlet CustomTableView *contentTableView;
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
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	BOOL bFromSubview;
	
	BOOL bFavorites;
	
	BOOL bMOARLoading;

	NSMutableArray *currentPhotosArray;
}

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) SubRedditItem *subReddit;
@property (nonatomic) BOOL bFavorites;

- (IBAction)onMOARButton:(id)sender;
- (IBAction)onShowType:(id)sender;
- (void)onSelectPhoto:(PhotoItem *)photo;

@end
