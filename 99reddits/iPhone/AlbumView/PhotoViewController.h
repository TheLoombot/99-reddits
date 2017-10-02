//
//  PhotoViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/14/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"
#import "ASIHTTPRequestDelegate.h"
#import "MaximizeActivity.h"

@interface PhotoViewController : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource, UIActionSheetDelegate, MaximizeActivityDelegate> {
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	
	SubRedditItem *subReddit;
	
	BOOL disappearForSubview;

	UIBarButtonItem *favoriteWhiteItem;
	UIBarButtonItem *favoriteRedItem;
	
	BOOL bFavorites;
}

@property (nonatomic, strong) SubRedditItem *subReddit;
@property (nonatomic) NSInteger testindex;
@property (nonatomic) BOOL disappearForSubview;
@property (nonatomic) BOOL bFavorites;

@end
