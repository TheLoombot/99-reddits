//
//  PhotoViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"
#import "ASIHTTPRequestDelegate.h"
#import "MaximizeActivity.h"

@interface PhotoViewControllerPad : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource, UIActionSheetDelegate, UIPopoverControllerDelegate, MaximizeActivityDelegate> {
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	
	SubRedditItem *subReddit;
	NSInteger index;
	
	BOOL shouldReleaseCaches;
	
	BOOL disappearForSubview;
	
	BOOL sharing;
	NSInteger sharingIndex;

	IBOutlet UIToolbar *rightItem;
	IBOutlet UIBarButtonItem *actionItem;
	UIBarButtonItem *commentItem;
	UIBarButtonItem *favoriteWhiteItem;
	UIBarButtonItem *favoriteRedItem;
	
	BOOL bFavorites;
	
	UIPopoverController *sharePopoverController;
	UIActionSheet *favoriteActionSheet;
}

@property (nonatomic, strong) SubRedditItem *subReddit;
@property (nonatomic) NSInteger testIndex;
@property (nonatomic) BOOL disappearForSubview;
@property (nonatomic) BOOL bFavorites;

- (IBAction)onCommentButton:(id)sender;
- (IBAction)onActionButton:(id)sender;
- (IBAction)onFavoriteButton:(id)sender;

- (IBAction)onPrevPhotoButton:(id)sender;
- (IBAction)onNextPhotoButton:(id)sender;

@end
