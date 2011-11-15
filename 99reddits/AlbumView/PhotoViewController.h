//
//  PhotoViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"
#import "ASIHTTPRequestDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "FBConnect.h"
#import "SA_OAuthTwitterController.h"


@class RedditsAppDelegate;

@interface PhotoViewController : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, FBRequestDelegate, FBDialogDelegate, FBSessionDelegate, SA_OAuthTwitterControllerDelegate> {
	RedditsAppDelegate *appDelegate;
	
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	
	NIImageMemoryCache *highQualityImageCache;
//	NIImageMemoryCache *thumbnailImageCache;
	
	SubRedditItem *subReddit;
	int index;
	
	BOOL releasing;
	
	BOOL disappearForSubview;
	
	BOOL sharing;
	int sharingType;
	int sharingIndex;
	
	NSData *sharingData;
	
	BOOL fbLogin;
	Facebook *_facebook;
	NSArray *_permissions;
	
	IBOutlet UIView *loadingView;
	
	UIInterfaceOrientation currentInterfaceOrientation;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) SubRedditItem *subReddit;
@property (nonatomic) int index;
@property (nonatomic) BOOL disappearForSubview;
@property (nonatomic) BOOL bFavorites;

@end
