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
	
	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	int refreshCount;
}

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;
- (void)onSettingsButton:(id)sender;

@end
