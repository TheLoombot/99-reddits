//
//  MainViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "NIProcessorHTTPRequest.h"


@class RedditsAppDelegate;
@class SubRedditItem;

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UITableView *contentTableView;
	IBOutlet UIToolbar *toolbar;
	
	NSMutableArray *subRedditsArray;
	
	NSOperationQueue *refreshQueue;
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	int refreshCount;
}

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit;
- (void)addSubReddit:(SubRedditItem *)subReddit;

@end
