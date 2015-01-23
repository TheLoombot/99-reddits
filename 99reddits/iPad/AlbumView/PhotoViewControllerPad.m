//
//  PhotoViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PhotoViewControllerPad.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "RedditsAppDelegate.h"
#import <Accounts/Accounts.h>
#import "UserDef.h"
#import <ImageIO/CGImageSource.h>
#import "PhotoViewPad.h"
#import <Social/Social.h>
#import "CommentViewControllerPad.h"

@interface PhotoViewControllerPad ()

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex;

- (void)shareImage:(UIImage *)image;

@end

@implementation PhotoViewControllerPad

@synthesize subReddit;
@synthesize index;
@synthesize disappearForSubview;
@synthesize bFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}

	activeRequests = nil;
	highQualityImageCache = nil;
	queue = nil;
}

- (void)didReceiveMemoryWarning {
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	[activeRequests removeAllObjects];
	[highQualityImageCache reduceMemoryUsage];

    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(0, 0, 25, 25);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"CommentBlueIcon.png"] forState:UIControlStateNormal];
	[commentButton addTarget:self action:@selector(onCommentButton:) forControlEvents:UIControlEventTouchUpInside];
	commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];

	UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
	redButton.frame = CGRectMake(0, 0, 25, 25);
	[redButton setBackgroundImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] forState:UIControlStateNormal];
	[redButton addTarget:self action:@selector(onFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
	favoriteRedItem = [[UIBarButtonItem alloc] initWithCustomView:redButton];

	UIButton *whiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	whiteButton.frame = CGRectMake(0, 0, 25, 25);
	[whiteButton setBackgroundImage:[UIImage imageNamed:@"FavoritesBlueIcon.png"] forState:UIControlStateNormal];
	[whiteButton addTarget:self action:@selector(onFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
	favoriteWhiteItem = [[UIBarButtonItem alloc] initWithCustomView:whiteButton];

	rightItem.translucent = YES;
	[rightItem setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];

	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

	activeRequests = [[NSMutableSet alloc] init];
	
//	highQualityImageCache = [[NIImageMemoryCache alloc] init];
//	[highQualityImageCache setMaxNumberOfPixelsUnderStress:1024 * 1024 * 2];

	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:3];

	self.titleLabel.font = [UIFont boldSystemFontOfSize:30];

	self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPhotoLarge" ofType:@"png"]];
	self.photoAlbumView.dataSource = self;
	self.photoAlbumView.backgroundColor = [UIColor blackColor];
	self.photoAlbumView.photoViewBackgroundColor = [UIColor blackColor];

	[self.photoAlbumView reloadData];
	[self.photoAlbumView moveToPageAtIndex:index animated:NO];
	
	[appDelegate checkNetworkReachable:YES];

	disappearForSubview = NO;
	
	sharing = NO;
	
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;
	
	self.toolbarOffset = 44;
	
	[self.view bringSubviewToFront:prevPhotoButton];
	[self.view bringSubviewToFront:nextPhotoButton];
	[self.view bringSubviewToFront:fullPhotoButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	if (!disappearForSubview) {
		[super viewWillAppear:YES];
	}
	
	disappearForSubview = NO;
	[self.photoAlbumView moveToPageAtIndex:self.photoAlbumView.centerPageIndex animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	self.titleLabelBar.hidden = NO;
	self.titleLabel.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!disappearForSubview) {
		[super viewWillDisappear:animated];
	}

	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:NO];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (!disappearForSubview) {
		sharing = NO;
	}
	
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;
}

- (IBAction)onActionButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}

	if (sharing)
		return;
	
	sharing = YES;
	sharingIndex = self.photoAlbumView.centerPageIndex;
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	
	[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:sharingIndex];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;

	if (actionSheet.tag == 101) {
		NSInteger currentIndex = self.photoAlbumView.centerPageIndex;
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:currentIndex];
		if ([appDelegate removeFromFavorites:photo]) {
			if (subReddit.photosArray.count == 0) {
				[self.navigationController popToRootViewControllerAnimated:YES];
				return;
			}
			
			if (currentIndex == subReddit.photosArray.count)
				currentIndex = subReddit.photosArray.count - 1;
			
			[highQualityImageCache removeAllObjects];
			[activeRequests removeAllObjects];
			[queue cancelAllOperations];
			
			[self.photoAlbumView reloadData];
			[self.photoAlbumView moveToPageAtIndex:currentIndex animated:NO];
			[self pagingScrollViewDidChangePages:self.photoAlbumView];
		}
	}
	
	favoriteActionSheet = nil;
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	return [NSString stringWithFormat:@"%ld", (long)photoIndex];
}

- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex {
//	if (![appDelegate checkNetworkReachable:NO])
//		return;
	
	if (photoIndex >= subReddit.photosArray.count)
		return;
	
	NSInteger identifier = photoIndex;
	NSNumber *identifierKey = [NSNumber numberWithInteger:identifier];
	
	if ([activeRequests containsObject:identifierKey]) {
		return;
	}

	if (![appDelegate isFullImage:source])
		source = [appDelegate getHugeImage:source];
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest __weak *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	readOp.tag = photoIndex;
	
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	[readOp setCompletionBlock:^{
		NSData *data = [readOp responseData];
		UIImage *image = [UIImage imageWithData:data];
		
		size_t imageCount = 1;
		if (image && subReddit.photosArray.count > photoIndex) {
//			if (image.size.width > 1024 || image.size.height > 1024) {
//				float w, h;
//				if (image.size.width > image.size.height) {
//					w = 1024;
//					h = image.size.height * w / image.size.width;
//				}
//				else {
//					h = 1024;
//					w = image.size.width * h / image.size.height;
//				}
//				
//				UIGraphicsBeginImageContext(CGSizeMake(w, h));
//				[image drawInRect:CGRectMake(0, 0, w, h)];
//				image = UIGraphicsGetImageFromCurrentImageContext();
//				UIGraphicsEndImageContext();
//			}

			BOOL shouldRefresh = NO;
//			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
//			if ([[[photo.urlString pathExtension] lowercaseString] isEqualToString:@"gif"]) {
				if (![highQualityImageCache objectWithName:photoIndexKey]) {
					[highQualityImageCache storeObject:image withName:photoIndexKey];
					shouldRefresh = YES;
				}
				
				if (photoIndex == self.photoAlbumView.centerPageIndex) {
					CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
					if (imageSource) {
						imageCount = CGImageSourceGetCount(imageSource);
						if (imageCount > 1) {
							[self.photoAlbumView setZoomingIsEnabled:NO];
							[self.photoAlbumView didLoadPhoto:image atIndex:photoIndex photoSize:photoSize];
							[self.photoAlbumView didLoadGif:data atIndex:photoIndex];
							
							shouldRefresh = NO;
						}
						CFRelease(imageSource);
					}
				}
//			}
//			else {
//				[highQualityImageCache storeObject:image withName:photoIndexKey];
//				shouldRefresh = YES;
//			}
			
			if (shouldRefresh) {
				[self.photoAlbumView setZoomingIsEnabled:YES];
				[self.photoAlbumView didLoadPhoto:image atIndex:photoIndex photoSize:photoSize];
			}
		}
		else {
			[self.photoAlbumView setZoomingIsEnabled:NO];
			[self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:photoSize];
		}
		
		if (photoIndex == self.photoAlbumView.centerPageIndex) {
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
			
			if (![photo isShowed]) {
//				photo.showed = YES;
				[appDelegate.showedSet addObject:photo.idString];
				subReddit.unshowedCount --;
			}
			
			if (sharing && photoIndex == sharingIndex && image) {
				[self shareImage:image];
			}
			else {
				sharing = NO;
			}
		}
		else {
			sharing = NO;
		}
		
		
		[activeRequests removeObject:identifierKey];
	}];
	
	[readOp setFailedBlock:^{
		[self.photoAlbumView setZoomingIsEnabled:NO];
		[self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:photoSize];
		
		if (photoIndex == self.photoAlbumView.centerPageIndex) {
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
			
			if (![photo isShowed]) {
//				photo.showed = YES;
				[appDelegate.showedSet addObject:photo.idString];
				subReddit.unshowedCount --;
			}
		}
		
		sharing = NO;
		
		[activeRequests removeObject:identifierKey];
	}];
	
	[readOp setQueuePriority:NSOperationQueuePriorityNormal];
	
	[activeRequests addObject:identifierKey];
	[queue addOperation:readOp];
}

// NIPhotoAlbumScrollViewDataSource
- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
	return subReddit.photosArray.count;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
	PhotoViewPad *photoView = nil;
	NSString *reuseIdentifier = @"PHOTO_VIEW";
	photoView = (PhotoViewPad *)[pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
	if (nil == photoView) {
		photoView = [[PhotoViewPad alloc] init];
		photoView.reuseIdentifier = reuseIdentifier;
		photoView.zoomingAboveOriginalSizeIsEnabled = YES;
	}
	
	photoView.photoScrollViewDelegate = self.photoAlbumView;
	photoView.photoViewController = self;
	[photoView setGifData:nil];

	return photoView;
}

- (UIImage *)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex:(NSInteger)photoIndex
                        photoSize:(NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading:(BOOL *)isLoading
          originalPhotoDimensions:(CGSize *)originalPhotoDimensions {
	
	if (photoIndex >= subReddit.photosArray.count)
		return nil;
	
	UIImage *image = nil;
	
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
	
	image = [highQualityImageCache objectWithName:photoIndexKey];
	if (image != nil) {
		self.photoAlbumView.zoomingIsEnabled = YES;
		*photoSize = NIPhotoScrollViewPhotoSizeOriginal;
		*originalPhotoDimensions = image.size;
		
		*isLoading = NO;
	}
	else {
		self.photoAlbumView.zoomingIsEnabled = NO;
		[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:photoIndex];
		
		*isLoading = YES;
	}
	
	return image;
}

- (void)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView stopLoadingPhotoAtIndex:(NSInteger)photoIndex {
	for (ASIHTTPRequest *op in [queue operations]) {
		if (op.tag == photoIndex) {
			[op cancel];
			NSNumber *identifierKey = [NSNumber numberWithInteger:photoIndex];
			[activeRequests removeObject:identifierKey];
		}
	}
}

- (void)pagingScrollViewDidChangePages:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
	if (self.photoAlbumView.centerPageIndex >= subReddit.photosArray.count)
		return;
	
	[super pagingScrollViewDidChangePages:photoAlbumScrollView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:self.photoAlbumView.centerPageIndex];
	UIImage *image = [highQualityImageCache objectWithName:photoIndexKey];
	
	if (image && ![photo isShowed]) {
//		photo.showed = YES;
		[appDelegate.showedSet addObject:photo.idString];
		subReddit.unshowedCount --;
	}
	
	if (sharing && self.photoAlbumView.centerPageIndex != sharingIndex) {
		sharing = NO;
	}
	
//	if ([[[photo.urlString pathExtension] lowercaseString] isEqualToString:@"gif"])
		[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:self.photoAlbumView.centerPageIndex];
	
	if (!bFavorites) {
		if ([appDelegate isFavorite:photo]) {
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
		}
		else {
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
		}
	}

	fullPhotoButton.enabled = ![appDelegate isFullImage:photo.urlString];
}

- (void)shareImage:(UIImage *)image {
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	
	NSArray *activityItems = @[image, photo.titleString, [NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]]];
	NSArray *applicationActivities = nil;
	NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
	activityViewController.excludedActivityTypes = excludedActivityTypes;
	
	sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
	sharePopoverController.delegate = self;
	[sharePopoverController presentPopoverFromBarButtonItem:actionItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

	sharing = NO;
}

// UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	if (popoverController == sharePopoverController) {
		sharePopoverController = nil;
	}
}

- (IBAction)onFavoriteButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}

	if (bFavorites) {
		favoriteActionSheet = [[UIActionSheet alloc] initWithTitle:nil
														  delegate:self
												 cancelButtonTitle:@"Cancel"
											destructiveButtonTitle:@"Remove from Favorites"
												 otherButtonTitles:nil];
		favoriteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		favoriteActionSheet.tag = 101;
		[favoriteActionSheet showFromBarButtonItem:favoriteRedItem animated:YES];
	}
	else {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
		if ([appDelegate isFavorite:photo]) {
			if ([appDelegate removeFromFavorites:photo]) {
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
			}
		}
		else {
			if ([appDelegate addToFavorites:photo]) {
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
			}
		}
	}
}

- (void)setSubReddit:(SubRedditItem *)_subReddit {
	subReddit = _subReddit;
}

- (IBAction)onPrevPhotoButton:(id)sender {
	[self.photoAlbumView moveToPreviousAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onNextPhotoButton:(id)sender {
	[self.photoAlbumView moveToNextAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onCommentButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}

	disappearForSubview = YES;
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	CommentViewControllerPad *commentViewController = [[CommentViewControllerPad alloc] initWithNibName:@"CommentViewControllerPad" bundle:nil];
	commentViewController.urlString = photo.permalinkString;
	UINavigationController *commentNavigationController = [[UINavigationController alloc] initWithRootViewController:commentViewController];
	[self presentViewController:commentNavigationController animated:YES completion:nil];
}

- (IBAction)onFullPhotoButton:(id)sender {
	NSInteger identifier = self.photoAlbumView.centerPageIndex;
	NSNumber *identifierKey = [NSNumber numberWithInteger:identifier];
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:identifier];
	[activeRequests removeObject:identifierKey];
	[highQualityImageCache removeObjectWithName:photoIndexKey];

	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[appDelegate addToFullImagesSet:photo.urlString];
	fullPhotoButton.enabled = NO;
	[self.photoAlbumView reloadData];
}

@end
