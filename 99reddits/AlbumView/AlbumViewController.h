//
//  AlbumViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"
#import "ASIHTTPRequestDelegate.h"
#import "NIProcessorHTTPRequest.h"


@class RedditsAppDelegate;
@class MainViewController;

@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate> {
	RedditsAppDelegate *appDelegate;
	MainViewController *mainViewController;
	
	IBOutlet UITableView *contentTableView;
	IBOutlet UIView *footerView;
	IBOutlet UIButton *moarButton;
	IBOutlet UIActivityIndicatorView *moarWaitingView;
	IBOutlet UITabBar *tabBar;
	IBOutlet UITabBarItem *hotItem;
	IBOutlet UITabBarItem *newItem;
	IBOutlet UITabBarItem *controversialItem;
	IBOutlet UITabBarItem *topItem;
	UITabBarItem *currentItem;

	SubRedditItem *currentSubReddit;
	SubRedditItem *subReddit;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	BOOL bFromSubview;
	
	BOOL bFavorites;
	
	BOOL bMOARLoading;
}

@property (nonatomic, assign) MainViewController *mainViewController;
@property (nonatomic, retain) SubRedditItem *subReddit;
@property (nonatomic) BOOL bFavorites;

- (IBAction)onMOARButton:(id)sender;
- (void)onSelectPhoto:(PhotoItem *)photo;

@end
