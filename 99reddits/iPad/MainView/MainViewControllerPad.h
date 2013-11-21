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
#import "MainViewLayoutPad.h"
#import "CustomRefreshControl.h"

@class RedditsAppDelegate;
@class SubRedditItem;

@interface MainViewControllerPad : UICollectionViewController <ASIHTTPRequestDelegate, PopoverControllerDelegate, MainViewLayoutPadDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UIBarButtonItem *settingsItem;
	IBOutlet UIBarButtonItem *editItem;
	IBOutlet UIBarButtonItem *doneItem;
	IBOutlet UIView *footerView;
	IBOutlet UIButton *addButton;
	CustomRefreshControl *refreshControl;

	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	int refreshCount;
	float scale;

	int lastAddedIndex;
	
	PopoverController *popoverController;
}

@property (nonatomic, assign) int lastAddedIndex;

- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onEditButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

- (void)reloadData;

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

- (void)showSubReddit:(SubRedditItem *)subReddit;
- (void)removeSubReddit:(SubRedditItem *)subReddit;

- (void)dismissPopover;

@end
