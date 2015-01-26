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

@class SubRedditItem;

@interface MainViewController : UITableViewController <ASIHTTPRequestDelegate> {
	IBOutlet UIBarButtonItem *settingsItem;
	IBOutlet UIBarButtonItem *editItem;
	IBOutlet UIBarButtonItem *doneItem;
	IBOutlet UIView *footerView;
	IBOutlet UIButton *addButton;
	UIRefreshControl *refreshControl;

	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	NSInteger refreshCount;

	NSInteger lastAddedIndex;
}

@property (nonatomic, assign) NSInteger lastAddedIndex;

- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onEditButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

- (void)reloadData;

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

@end
