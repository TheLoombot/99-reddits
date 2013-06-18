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
#import <MessageUI/MFMailComposeViewController.h>

@class RedditsAppDelegate;

@interface PhotoViewController : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
	RedditsAppDelegate *appDelegate;
	
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	
	NIImageMemoryCache *highQualityImageCache;
	
	SubRedditItem *subReddit;
	int index;
	
	BOOL releasing;
	
	BOOL disappearForSubview;
	
	BOOL sharing;
	int sharingType;
	int sharingIndex;
	
	NSData *sharingData;

	UIBarButtonItem *favoriteWhiteItem;
	UIBarButtonItem *favoriteRedItem;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) SubRedditItem *subReddit;
@property (nonatomic) int index;
@property (nonatomic) BOOL disappearForSubview;
@property (nonatomic) BOOL bFavorites;

@end
