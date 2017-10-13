//
//  PhotoViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/14/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "PhotoViewController.h"
#import "UserDef.h"
#import "PhotoView.h"
#import "CommentViewController.h"
#import "NSData+Extensions.h"
#import "_9reddits-Swift.h"

@interface PhotoViewController()

@property (strong, nonatomic) NSMutableDictionary *indexToCancelationTokens;

@end

@implementation PhotoViewController

@synthesize subReddit;
@synthesize bFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets: NO];

    self.indexToCancelationTokens = [[NSMutableDictionary<NSNumber *, ImageLoaderCancelationToken*> alloc] init];
	
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
	
    self.navigationItem.rightBarButtonItem = favoriteRedItem;

    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }

	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPhotoLarge" ofType:@"png"]];
	self.photoAlbumView.dataSource = self;
	self.photoAlbumView.backgroundColor = [UIColor blackColor];
	self.photoAlbumView.photoViewBackgroundColor = [UIColor blackColor];
	[self.photoAlbumView reloadData];
	[appDelegate checkNetworkReachable:YES];
	
	UIBarButtonItem *actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton)];
	
	UIBarButtonItem *commentButtonItem;
	commentButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentBlueIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onCommentButtonItem:)];
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
	[items insertObject:actionButtonItem atIndex:0];
	[items addObject:commentButtonItem];
	
	self.toolbar.items = items;
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isMovingToParentViewController) {
        //Go to `photoIndexToDisplay` only when being first pushed to the navigation stack, not when a presented view controller is getting dismissed.
        self.photoAlbumView.centerPageIndex = self.photoIndexToDisplay;
        [self.photoAlbumView moveToPageAtIndex:self.photoIndexToDisplay animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	self.titleLabelBar.hidden = NO;
	self.titleLabel.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;
}

- (void)onActionButton {

    NSInteger sharingIndex = self.photoAlbumView.centerPageIndex;
    PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];

    NSURL *sourceURL = [photo photoViewControllerURL];
    if (!sourceURL) {
        return;
    }

    NSString *title = [NSString stringWithFormat:@"%@\n", photo.titleString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]];

    if ([sourceURL.absoluteString.pathExtension isEqualToString:@"gif"]) {

        [ImageLoader loadGifWithURL:sourceURL success:^(NSData * _Nonnull gifData) {
            [self shareGifData:gifData title:title url:url];
        } failure:^(NSError * _Nonnull error) {
            //TODO: alert
        }];

    } else {

        [ImageLoader loadImageWithURL:sourceURL success:^(UIImage * _Nonnull image) {
            [self shareImage:image title:title url:url];
        } failure:^(NSError * _Nonnull error) {
            //TODO: alert
        }];
    }
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
			
            if (currentIndex == subReddit.photosArray.count) {
                currentIndex = subReddit.photosArray.count - 1;
            }
			
			[self.photoAlbumView reloadData];
			[self.photoAlbumView moveToPageAtIndex:currentIndex animated:NO];
			[self pagingScrollViewDidChangePages:self.photoAlbumView];
		}
	}
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
        photoView = [[PhotoView alloc] init];
        photoView.reuseIdentifier = reuseIdentifier;
    }

    photoView.zoomingAboveOriginalSizeIsEnabled = YES;
    photoView.photoScrollViewDelegate = self.photoAlbumView;

    return photoView;
}

- (UIImage *)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex:(NSInteger)photoIndex
                        photoSize:(NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading:(BOOL *)isLoading
          originalPhotoDimensions:(CGSize *)originalPhotoDimensions {

    if (photoIndex >= subReddit.photosArray.count) {
        return nil;
    }

    //TODO: maybe put `getHugeImage` in PhotoItem class
    PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
    NSURL *photoURL = [photo photoViewControllerURL];
    if (!photoURL) {
        return nil;
    }

    if ([photoURL.absoluteString.pathExtension isEqualToString:@"gif"]) {
        [self loadGifFromPhoto:photo atIndex:photoIndex isLoading:isLoading];
    } else {
        [self loadImageFromPhoto:photo atIndex:photoIndex isLoading:isLoading];
    }

    return nil;
}

- (void)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView stopLoadingPhotoAtIndex:(NSInteger)photoIndex {
    ImageLoaderCancelationToken *token = self.indexToCancelationTokens[@(photoIndex)];
    [token cancel];
}

- (void)pagingScrollViewDidChangePages:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
    if (self.photoAlbumView.centerPageIndex >= subReddit.photosArray.count) {
        return;
    }
	
	[super pagingScrollViewDidChangePages:photoAlbumScrollView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];

    if (self.photoAlbumView.centerPageIndex != 0 ){
        //When jumping into a specific photo with `photoIndexToDisplay`, this delegate method always gets called twice by Nimbus the first time (??) and the first time is always with index 0. We don't mark index zero as seen this way ever, and instead rely on marking it when it gets loaded.
        [self markPhotoSeenIfNeessary:photo atIndex:self.photoAlbumView.centerPageIndex];
    }
	
	if (!bFavorites) {
		if ([appDelegate isFavorite:photo]) {
			self.navigationItem.rightBarButtonItem = favoriteRedItem;
		}
		else {
			self.navigationItem.rightBarButtonItem = favoriteWhiteItem;
		}
	}
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
	}
	else {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
		if ([appDelegate isFavorite:photo]) {
			if ([appDelegate removeFromFavorites:photo]) {
				self.navigationItem.rightBarButtonItem = favoriteWhiteItem;
			}
		}
		else {
			if ([appDelegate addToFavorites:photo]) {
				self.navigationItem.rightBarButtonItem = favoriteRedItem;
			}
		}
	}
}

- (void)onCommentButtonItem:(id)sender {
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
	commentViewController.urlString = photo.permalinkString;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:commentViewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UIActivityViewController sharing

- (void)shareImage:(UIImage *)image title:(NSString *)title url:(NSURL *)url {
    [self shareActivityItems:@[image, title, url]];
}

- (void)shareGifData:(NSData *)data title:(NSString *)title url:(NSURL *)url {
    [self shareActivityItems:@[data, title, url]];
}

- (void)shareActivityItems:(NSArray *)activityItems {

    NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePrint];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[]];
    activityViewController.excludedActivityTypes = excludedActivityTypes;

    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)loadGifFromPhoto:(PhotoItem *)photo atIndex:(NSInteger)photoIndex isLoading:(BOOL *)isLoading {

    NSURL *url = [photo photoViewControllerURL];

    ImageLoaderCancelationToken *token = [ImageLoader loadGifWithURL:url success:^(NSData * _Nonnull gifData) {
        UIImage *imageFromData = [UIImage imageWithData:gifData];
        [self.photoAlbumView didLoadPhoto:imageFromData atIndex:photoIndex photoSize:NIPhotoScrollViewPhotoSizeOriginal error:NO];
        [self.photoAlbumView didLoadGif:gifData atIndex:photoIndex];
        [self markPhotoSeenIfNeessary:photo atIndex:photoIndex];
    } failure:^(NSError * _Nonnull error) {
        [self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:NIPhotoScrollViewPhotoSizeOriginal error:YES];
        [self markPhotoSeenIfNeessary:photo atIndex:photoIndex];
    }];

    self.indexToCancelationTokens[@(photoIndex)] = token;

    *isLoading = YES;
}

- (void)loadImageFromPhoto:(PhotoItem *)photo atIndex:(NSInteger)photoIndex isLoading:(BOOL *)isLoading {

    NSURL *url = [photo photoViewControllerURL];

    ImageLoaderCancelationToken *token = [ImageLoader loadImageWithURL:url success:^(UIImage * _Nonnull image) {
        UIImage *imageWithoutScale = [UIImage imageWithCGImage:image.CGImage];
        [self.photoAlbumView didLoadPhoto:imageWithoutScale atIndex:photoIndex photoSize:NIPhotoScrollViewPhotoSizeOriginal error:NO];
        [self markPhotoSeenIfNeessary:photo atIndex:photoIndex];
    } failure:^(NSError * _Nonnull error) {
        [self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:NIPhotoScrollViewPhotoSizeOriginal error:YES];
        [self markPhotoSeenIfNeessary:photo atIndex:photoIndex];
    }];

    self.indexToCancelationTokens[@(photoIndex)] = token;

    *isLoading = YES;
}

- (void)markPhotoSeenIfNeessary:(PhotoItem *)photo atIndex:(NSInteger)idx {

    //Only mark the photo as seen if its corresponding index matches with what's currently being shown at `self.photoView.centerPageIndex`
    if (idx != self.photoAlbumView.centerPageIndex) {
        return;
    }

    if (![photo isShowed]) {
        [appDelegate.showedSet addObject:photo.idString];
        subReddit.unshowedCount --;
    }
}

@end
