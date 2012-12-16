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
#import "PopoverController.h"
#import "CustomTableView.h"

@class RedditsAppDelegate;
@class SubRedditItem;

@interface MainViewControllerPad : UIViewController  <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate, PopoverControllerDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet CustomTableView *contentTableView;
	IBOutlet UIBarButtonItem *refreshItem;
	IBOutlet UIBarButtonItem *settingsItem;
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
	
	PopoverController *popoverController;
}

- (IBAction)onRefreshButton:(id)sender;
- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onEditButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

- (void)showSubRedditAtIndex:(int)index;
- (void)removeSubRedditAtIndex:(int)index;

- (void)dismissPopover;

@end
