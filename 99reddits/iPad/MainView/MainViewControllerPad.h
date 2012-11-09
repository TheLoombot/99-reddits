//
//  MainViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "NIProcessorHTTPRequest.h"

@class RedditsAppDelegate;
@class SubRedditItem;

@interface MainViewControllerPad : UIViewController  <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UITableView *contentTableView;
	IBOutlet UIToolbar *leftItemsBar;
	IBOutlet UIToolbar *rightItemsBar;
	IBOutlet UIBarButtonItem *refreshItem;
	IBOutlet UIBarButtonItem *settingsItem;
	IBOutlet UIBarButtonItem *spaceItem;
	IBOutlet UIBarButtonItem *editItem;
	IBOutlet UIBarButtonItem *doneItem;
	IBOutlet UIBarButtonItem *addItem;

	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	int refreshCount;
	float scale;
}

- (IBAction)onRefreshButton:(id)sender;
- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onEditButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

- (void)showSubRedditAtIndex:(int)index;
- (void)removeSubRedditAtIndex:(int)index;

@end
