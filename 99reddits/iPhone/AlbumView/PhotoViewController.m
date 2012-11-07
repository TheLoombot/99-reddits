//
//  PhotoViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "RedditsAppDelegate.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>
#import "UserDef.h"
#import "SA_OAuthTwitterEngine.h"
#import <ImageIO/CGImageSource.h>
#import "PhotoView.h"


@interface PhotoViewController ()

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex;

- (void)shareImage:(UIImage *)image data:(NSData *)data;

- (void)shareToTwitter;

@end

@implementation PhotoViewController

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
	NI_RELEASE_SAFELY(_facebook);
	NI_RELEASE_SAFELY(_permissions);
	NI_RELEASE_SAFELY(sharingData);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWITTER_SUCCESS" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWITTER_FAILED" object:nil];
	
	[self releaseObjects];
	
	[subReddit release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[self releaseObjects];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)] autorelease];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	highQualityImageCache = [[NIImageMemoryCache alloc] init];
	
	[highQualityImageCache setMaxNumberOfPixelsUnderStress:1024 * 1024 * 3];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPhotoLarge" ofType:@"png"]];
	self.photoAlbumView.dataSource = self;
	self.photoAlbumView.backgroundColor = [UIColor blackColor];
	self.photoAlbumView.photoViewBackgroundColor = [UIColor blackColor];
	
	[self.photoAlbumView reloadData];
	[self.photoAlbumView moveToPageAtIndex:index animated:NO];
	
	[appDelegate checkNetworkReachable:YES];
	
	UIBarButtonItem *actionButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton)] autorelease];
	UIBarButtonItem *spaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	spaceButtonItem.width = 32;
	
	NSMutableArray *items = [[[NSMutableArray alloc] initWithArray:self.toolbar.items] autorelease];
	[items insertObject:actionButtonItem atIndex:0];
	[items addObject:spaceButtonItem];
	
	self.toolbar.items = items;
	
	disappearForSubview = NO;
	
	sharing = NO;
	
	fbLogin = NO;
	_permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
	_facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterSuccess) name:@"TWITTER_SUCCESS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterFailed) name:@"TWITTER_FAILED" object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self releaseObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	if (disappearForSubview) {
		if (interfaceOrientation == currentInterfaceOrientation)
			return YES;
		else
			return NO;
	}
	
	currentInterfaceOrientation = interfaceOrientation;
	return YES;
}

- (BOOL)shouldAutorotate {
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	if (disappearForSubview) {
		if (interfaceOrientation == currentInterfaceOrientation)
			return YES;
		else
			return NO;
	}
	
	currentInterfaceOrientation = interfaceOrientation;
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
//	if (!disappearForSubview) {
//		[self toggleChromeVisibility];
//	}
	
	disappearForSubview = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (!disappearForSubview) {
		[self releaseObjects];
		
		sharing = NO;
		
//		[appDelegate saveToDefaults];
	}
}

- (void)onActionButton {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"Save Photo", @"Email Photo", @"Tweet", @"Share on Facebook", @"See Comments on reddit", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.tag = 100;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 100) {
		if (buttonIndex == actionSheet.cancelButtonIndex)
			return;
		
		if (buttonIndex == 4) {
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:photo.permalinkString]];
			return;
		}

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
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
			if ([[[photo.urlString pathExtension] lowercaseString] isEqualToString:@"gif"]) {
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
			}
			else {
				[highQualityImageCache storeObject:image withName:photoIndexKey];
				shouldRefresh = YES;
			}
			
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
	PhotoView *photoView = nil;
	NSString *reuseIdentifier = @"PHOTO_VIEW";
	photoView = (PhotoView *)[pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
	if (nil == photoView) {
		photoView = [[[PhotoView alloc] init] autorelease];
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
	} else {
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
	
	if ([[[photo.urlString pathExtension] lowercaseString] isEqualToString:@"gif"])
		[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:self.photoAlbumView.centerPageIndex];

	if (!bFavorites) {
		if ([appDelegate isFavorite:photo])
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)] autorelease];
		else
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesWhiteIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)] autorelease];
	}
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)shareImage:(UIImage *)image data:(NSData *)data {
	if (sharingType == 0) {
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
	else if (sharingType == 1) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
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
			[self presentModalViewController:mailComposeViewController animated:YES];
			[mailComposeViewController release];
		}
	}
	else if (sharingType == 2) {
		if (appDelegate.tweetEnabled) {
			TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];

			if ([TWTweetComposeViewController canSendTweet]) {
				PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];

				[tweetComposeViewController setInitialText:photo.titleString];
				[tweetComposeViewController addImage:image];
				[tweetComposeViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]]];
			}
			
			tweetComposeViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
				[tweetComposeViewController dismissModalViewControllerAnimated:YES];
			};
			
			[self presentModalViewController:tweetComposeViewController animated:YES];
			[tweetComposeViewController release];
		}
		else {
			if(![appDelegate.engine isAuthorized]){  
				UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:appDelegate.engine delegate:self];
				if (controller) {
					disappearForSubview = YES;
					[self presentModalViewController:controller animated:YES];
				}
			}
			else {
				[self shareToTwitter];
			}
		}
	}
	else if (sharingType == 3) {
		[appDelegate.window addSubview:loadingView];
		
		[sharingData release];
		sharingData = [data retain];
		
		if (fbLogin)
			[self performSelector:@selector(uploadToFacebook)];
		else
			[self performSelector:@selector(loginFacebook)];
	}

	sharing = NO;
}

// Facebook
- (void)loginFacebook {
	if (!fbLogin) {
		[_facebook authorize:_permissions];
	}
}

- (void)logoutFacebook {
	[_facebook logout:self];
}

- (BOOL)isLoginFacebook {
	return fbLogin;
}

- (void)facebookPublishInfo {
	[_facebook requestWithGraphPath:@"me/permissions" andDelegate:self];
}

- (void)uploadToFacebook {
	[appDelegate.window addSubview:loadingView];
	[self facebookPublishInfo];
}

- (void)uploadPhotoToFacebook {
	[appDelegate.window addSubview:loadingView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   photo.titleString, @"name", 
								   @"Found using the 99 reddits iOS app!", @"caption", 
								   [NSString stringWithFormat:@"http://redd.it/%@", photo.idString], @"link", 
								   photo.urlString, @"picture", 
                                   nil];
    
	[_facebook dialog:@"feed" andParams:params andDelegate:self];
}

/**
 * Callback for facebook login
 */ 
-(void)fbDidLogin {
	fbLogin = YES;
	
	[self performSelector:@selector(uploadToFacebook)];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	[loadingView removeFromSuperview];
	
	if (cancelled)
		return;
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't login to Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

/**
 * Callback for facebook logout
 */ 
-(void)fbDidLogout {
	fbLogin = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
	[loadingView removeFromSuperview];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't share on Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		if ([result objectForKey:@"owner"]) {
			[loadingView removeFromSuperview];
		}
		else {
			[loadingView removeFromSuperview];
			
			[self uploadPhotoToFacebook];
		}
	}
	else {
		[loadingView removeFromSuperview];
	}
}

- (void)dialogDidComplete:(FBDialog *)dialog {
	[loadingView removeFromSuperview];
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
	[loadingView removeFromSuperview];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
	[loadingView removeFromSuperview];
}

- (void)shareToTwitter {
	[appDelegate.window addSubview:loadingView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	[appDelegate.engine sendUpdate:[NSString stringWithFormat:@"%@ http://redd.it/%@", photo.titleString, photo.idString]];
}

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
	[self shareToTwitter];
}

- (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't login to Twitter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller {
}

- (void)onTwitterSuccess {
	[loadingView removeFromSuperview];
}

- (void)onTwitterFailed {
	[loadingView removeFromSuperview];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Can't share on Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)onFavoriteButton:(id)sender {
	if (bFavorites) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:@"Remove from Favorites" 
														otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		actionSheet.tag = 101;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
	else {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
		if ([appDelegate isFavorite:photo]) {
			if ([appDelegate removeFromFavorites:photo]) {
				self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesWhiteIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)] autorelease];
			}
		}
		else {
			if ([appDelegate addToFavorites:photo]) {
				self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavoriteButton:)] autorelease];
			}
		}
	}
}

- (void)setSubReddit:(SubRedditItem *)_subReddit {
	[subReddit release];
	subReddit = [_subReddit retain];
}

@end
