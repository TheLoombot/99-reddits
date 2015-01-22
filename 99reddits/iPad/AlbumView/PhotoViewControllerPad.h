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
#import <MessageUI/MFMailComposeViewController.h>

@class RedditsAppDelegate;

@interface PhotoViewControllerPad : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
	RedditsAppDelegate *appDelegate;
	
	NSOperationQueue *queue;
	
	NSMutableSet *activeRequests;
	
	NIImageMemoryCache *highQualityImageCache;
	
	SubRedditItem *subReddit;
	NSInteger index;
	
	BOOL releasing;
	
	BOOL disappearForSubview;
	
	BOOL sharing;
	NSInteger sharingType;
	NSInteger sharingIndex;
	
	NSData *sharingData;

	IBOutlet UIToolbar *rightItem;
	IBOutlet UIBarButtonItem *actionItem;
	UIBarButtonItem *commentItem;
	UIBarButtonItem *favoriteWhiteItem;
	UIBarButtonItem *favoriteRedItem;
	
	BOOL bFavorites;
	
	UIActionSheet *actionSheet;
}

@property (nonatomic, strong) SubRedditItem *subReddit;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL disappearForSubview;
@property (nonatomic) BOOL bFavorites;

- (IBAction)onCommentButton:(id)sender;
- (IBAction)onActionButton:(id)sender;
- (IBAction)onFavoriteButton:(id)sender;

- (IBAction)onPrevPhotoButton:(id)sender;
- (IBAction)onNextPhotoButton:(id)sender;
- (IBAction)onFullPhotoButton:(id)sender;

@end
