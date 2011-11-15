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


@class RedditsAppDelegate;

@interface AlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UITableView *contentTableView;

	SubRedditItem *subReddit;
	NSMutableArray *cellArray;
	
	NSOperationQueue *queue;
	
	NSMutableSet* activeRequests;
	NIImageMemoryCache* thumbnailImageCache;
	
	BOOL bFromSubview;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) SubRedditItem *subReddit;
@property (nonatomic) BOOL bFavorites;

- (void)onSelectPhoto:(PhotoItem *)photo;

@end
