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
	UIRefreshControl *refreshControl;
	NSMutableArray *subRedditsArray;
	NSInteger refreshCount;
	NSInteger lastAddedIndex;
}

@property (nonatomic, assign) NSInteger lastAddedIndex;

- (void)reloadData;
- (void)addSubReddit:(SubRedditItem *)subReddit;

@end
