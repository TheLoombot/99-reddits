//
//  MainViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "NIProcessorHTTPRequest.h"

@class RedditsAppDelegate;
@class SubRedditItem;

@interface MainViewController : UITableViewController <ASIHTTPRequestDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UIBarButtonItem *settingsItem;
	IBOutlet UIBarButtonItem *editItem;
	IBOutlet UIBarButtonItem *doneItem;
	IBOutlet UIBarButtonItem *addItem;
	IBOutlet UIView *footerView;
	IBOutlet UIButton *addButton;
	UIRefreshControl *refreshControl;

	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	int refreshCount;

	int lastAddedIndex;
}

@property (nonatomic, assign) int lastAddedIndex;

- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onEditButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

- (void)reloadData;

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

@end
