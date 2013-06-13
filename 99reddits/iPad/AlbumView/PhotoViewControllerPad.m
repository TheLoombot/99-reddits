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

- (void)shareImage:(UIImage *)image data:(NSData *)data;

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

- (void)releaseObjects {
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}

	NI_RELEASE_SAFELY(activeRequests);
	NI_RELEASE_SAFELY(highQualityImageCache);
	NI_RELEASE_SAFELY(queue);
	NI_RELEASE_SAFELY(sharingData);
}

- (void)dealloc {
	[self releaseObjects];
	
	[subReddit release];
	
	[loadingView release];
	[commentItem release];
	[actionItem release];
	[favoriteWhiteItem release];
	[favoriteRedItem release];
	
	[actionSheet release];
	[super dealloc];
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
	
	favoriteRedItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)];
	favoriteWhiteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesWhiteIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)];

	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];

	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

	activeRequests = [[NSMutableSet alloc] init];
	
	highQualityImageCache = [[NIImageMemoryCache alloc] init];
	
	[highQualityImageCache setMaxNumberOfPixelsUnderStress:1024 * 1024 * 2];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:3];

	self.titleLabel.font = [UIFont boldSystemFontOfSize:30];

	self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPhotoLarge" ofType:@"png"]];
	self.photoAlbumView.dataSource = self;
	self.photoAlbumView.backgroundColor = [UIColor blackColor];
	self.photoAlbumView.photoViewBackgroundColor = [UIColor blackColor];
	
	[self.photoAlbumView reloadData];
//	[self.photoAlbumView moveToPageAtIndex:index animated:NO];
	
	[appDelegate checkNetworkReachable:YES];

	
	disappearForSubview = NO;
	
	sharing = NO;
	
	self.titleLabel.hidden = YES;
	
	self.toolbarOffset = 44;
	
	[self.view bringSubviewToFront:prevPhotoButton];
	[self.view bringSubviewToFront:nextPhotoButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	[self.photoAlbumView moveToPageAtIndex:index animated:NO];
	
	[appDelegate unsetNavAppearance];
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	self.titleLabel.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!disappearForSubview) {
		[super viewWillDisappear:animated];
		[appDelegate setNavAppearance];
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBack.png"] forBarMetrics:UIBarMetricsDefault];
	}

	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
		[actionSheet release];
		actionSheet = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (!disappearForSubview) {
		[self releaseObjects];
		
		sharing = NO;
		
//		[appDelegate saveToDefaults];
	}
}

- (IBAction)onActionButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
		if (actionSheet.tag == 100) {
			[actionSheet release];
			actionSheet = nil;
			return;
		}
		else {
			[actionSheet release];
			actionSheet = nil;
		}
	}
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Save Photo", @"Email Photo", @"Tweet", @"Share on Facebook", @"Copy Image", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.tag = 100;
	[actionSheet showFromBarButtonItem:actionItem animated:YES];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)as didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 100) {
		if (buttonIndex == actionSheet.cancelButtonIndex)
			return;
		
		if (sharing)
			return;
		
		sharing = YES;
		sharingType = buttonIndex;
		sharingIndex = self.photoAlbumView.centerPageIndex;
		
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
		
		[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:sharingIndex];
	}
	else if (actionSheet.tag == 101) {
		if (buttonIndex == actionSheet.cancelButtonIndex)
			return;
		
		int currentIndex = self.photoAlbumView.centerPageIndex;
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
	
	[actionSheet release];
	actionSheet = nil;
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	return [NSString stringWithFormat:@"%d", photoIndex];
}

- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex {
	//	if (![appDelegate checkNetworkReachable:NO])
	//		return;
	
	if (photoIndex >= subReddit.photosArray.count)
		return;
	
	NSInteger identifier = photoIndex;
	NSNumber *identifierKey = [NSNumber numberWithInt:identifier];
	
	if ([activeRequests containsObject:identifierKey]) {
		return;
	}
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	readOp.tag = photoIndex;
	
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	[readOp setCompletionBlock:^{
		NSData *data = [readOp responseData];
		UIImage *image = [UIImage imageWithData:data];
		
		size_t imageCount = 1;
		if (image && subReddit.photosArray.count > photoIndex) {
			if (image.size.width > 1024 || image.size.height > 1024) {
				float w, h;
				if (image.size.width > image.size.height) {
					w = 1024;
					h = image.size.height * w / image.size.width;
				}
				else {
					h = 1024;
					w = image.size.width * h / image.size.height;
				}
				
				UIGraphicsBeginImageContext(CGSizeMake(w, h));
				[image drawInRect:CGRectMake(0, 0, w, h)];
				image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
			}
			
			BOOL shouldRefresh = NO;
//			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
//			if ([[[photo.urlString pathExtension] lowercaseString] isEqualToString:@"gif"]) {
				if (![highQualityImageCache objectWithName:photoIndexKey]) {
					[highQualityImageCache storeObject:image withName:photoIndexKey];
					shouldRefresh = YES;
				}
				
				if (photoIndex == self.photoAlbumView.centerPageIndex) {
					CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
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
				[self shareImage:image data:data];
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
		photoView = [[[PhotoViewPad alloc] init] autorelease];
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
			NSNumber *identifierKey = [NSNumber numberWithInt:photoIndex];
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
		if ([appDelegate isFavorite:photo])
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
		else
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
	}
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareImage:(UIImage *)image data:(NSData *)data {
	if (sharingType == 0) {
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
	else if (sharingType == 1) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[[MFMailComposeViewController alloc] init] autorelease];
			mailComposeViewController.mailComposeDelegate = self;
			
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
			[mailComposeViewController setTitle:photo.titleString];
			[mailComposeViewController setSubject:photo.titleString];
			[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"\n\nFound this on reddit:\nhttp://redd.it/%@\n\nDownload 99 reddits for your iPhone:\nhttp://itunes.apple.com/us/app/99-reddits/id474846610?mt=8", photo.idString] isHTML:NO];
			
			NSString *extension = [[photo.urlString pathExtension] lowercaseString];
			NSString *mimeType;
			if ([extension isEqualToString:@"gif"]) {
				mimeType = @"image/gif";
			}
			else if ([extension isEqualToString:@"png"]) {
				mimeType = @"image/png";
			}
			else if ([extension isEqualToString:@"tiff"] || [extension isEqualToString:@"tif"]) {
				mimeType = @"image/tiff";
			}
			else if ([extension isEqualToString:@"bmp"]) {
				mimeType = @"image/bmp";
			}
			else {
				mimeType = @"image/jpeg";
			}
			
			[mailComposeViewController addAttachmentData:data mimeType:mimeType fileName:[photo.urlString lastPathComponent]];
			
			disappearForSubview = YES;
			[self presentViewController:mailComposeViewController animated:YES completion:nil];
		}
	}
	else if (sharingType == 2) {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
		
		SLComposeViewController *tweetComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[tweetComposeViewController setInitialText:photo.titleString];
		[tweetComposeViewController addImage:image];
		[tweetComposeViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]]];
		
		tweetComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
			[tweetComposeViewController dismissViewControllerAnimated:YES completion:nil];
		};
		
		[self presentViewController:tweetComposeViewController animated:YES completion:nil];
	}
	else if (sharingType == 3) {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
		
		SLComposeViewController *facebookComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[facebookComposeViewController setInitialText:photo.titleString];
		[facebookComposeViewController addImage:image];
		[facebookComposeViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]]];
		
		facebookComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
			[facebookComposeViewController dismissViewControllerAnimated:YES completion:nil];
		};
		
		[self presentViewController:facebookComposeViewController animated:YES completion:nil];
	}
	else if (sharingType == 4) {
		NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setData:imageData forPasteboardType:@"public.jpeg"];
	}

	sharing = NO;
}

- (IBAction)onFavoriteButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
		[actionSheet release];
		actionSheet = nil;
	}

	if (bFavorites) {
		if (actionSheet) {
			[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
			if (actionSheet.tag == 101) {
				[actionSheet release];
				actionSheet = nil;
				return;
			}
			else {
				[actionSheet release];
				actionSheet = nil;
			}
		}
		
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:@"Remove from Favorites"
														otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		actionSheet.tag = 101;
		[actionSheet showFromBarButtonItem:favoriteRedItem animated:YES];
	}
	else {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
		if ([appDelegate isFavorite:photo]) {
			if ([appDelegate removeFromFavorites:photo])
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
		}
		else {
			if ([appDelegate addToFavorites:photo])
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
		}
	}
}

- (void)setSubReddit:(SubRedditItem *)_subReddit {
	[subReddit release];
	subReddit = [_subReddit retain];
}

- (IBAction)onPrevPhotoButton:(id)sender {
	[self.photoAlbumView moveToPreviousAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onNextPhotoButton:(id)sender {
	[self.photoAlbumView moveToNextAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onCommentButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
		[actionSheet release];
		actionSheet = nil;
	}

	disappearForSubview = YES;
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	CommentViewControllerPad *commentViewController = [[CommentViewControllerPad alloc] initWithNibName:@"CommentViewControllerPad" bundle:nil];
	commentViewController.urlString = photo.permalinkString;
	[self presentViewController:commentViewController animated:YES completion:nil];
	[commentViewController release];
}

@end
