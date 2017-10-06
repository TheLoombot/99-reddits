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
#import "TitleProvider.h"
#import "URLProvider.h"
#import "NSData+Extensions.h"
#import "_9reddits-Swift.h"

@interface PhotoViewController()

@property (strong, nonatomic) NSMutableDictionary *indexToCancelationTokens;

@end

@implementation PhotoViewController

@synthesize subReddit;
@synthesize testindex;
@synthesize disappearForSubview;
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
	
	disappearForSubview = NO;

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
	if (!disappearForSubview) {
		[super viewWillAppear:animated];
	}
	disappearForSubview = NO;
    self.photoAlbumView.centerPageIndex = self.testindex;
	[self.photoAlbumView moveToPageAtIndex:self.testindex animated:YES];
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

    NSString *source = [photo photoViewControllerURLString];

    ImageLoaderCancelationToken *token = [ImageLoader loadWithUrlString:source success:^(UIImage * _Nonnull image) {

        NSString *title = [NSString stringWithFormat:@"%@\n", photo.titleString];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]];
        NSData *imageData = UIImagePNGRepresentation(image);
        [self shareImage:imageData title:title url:url];

    } failure:^(NSError * _Nonnull error) {
        //TODO: log failure
    }];
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
    NSString *source = [photo photoViewControllerURLString];

    ImageLoaderCancelationToken *token = [ImageLoader loadWithUrlString:source success:^(UIImage * _Nonnull image) {
        //Nuke's `Decompressor` gives you a `UIImage` with the scale property set, which changes the image's reported size on different devices. Here we lose the reported scale and take the size of the CGImage bitmap.
        UIImage *imageWithoutScale = [UIImage imageWithCGImage:image.CGImage];
        [self.photoAlbumView didLoadPhoto:imageWithoutScale atIndex:photoIndex photoSize:NIPhotoScrollViewPhotoSizeOriginal error:NO];

        //In the old implementation didLoadGif was called after didLoadPhoto
        NSData *imageData = UIImagePNGRepresentation(image);
        if ([imageData isGif]) {
            [self.photoAlbumView didLoadGif:imageData atIndex:photoIndex];
        }

        [self markPhotoSeenIfNeessary:photo];

    } failure:^(NSError * _Nonnull error) {
        [self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:*photoSize error:YES];

        [self markPhotoSeenIfNeessary:photo];
    }];

    self.indexToCancelationTokens[@(photoIndex)] = token;

    *isLoading = YES;

    return nil;
}

- (void)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView stopLoadingPhotoAtIndex:(NSInteger)photoIndex {
    ImageLoaderCancelationToken *token = self.indexToCancelationTokens[@(photoIndex)];
    [token cancel];
}

- (void)pagingScrollViewDidChangePages:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
	if (self.photoAlbumView.centerPageIndex >= subReddit.photosArray.count)
		return;
	
	[super pagingScrollViewDidChangePages:photoAlbumScrollView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	
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
	disappearForSubview = YES;
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
	commentViewController.urlString = photo.permalinkString;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:commentViewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)shareImage:(NSData *)data title:(NSString *)title url:(NSURL *)url {
	TitleProvider *titleItem = [[TitleProvider alloc] initWithPlaceholderItem:title];
	URLProvider *urlItem = [[URLProvider alloc] initWithPlaceholderItem:url];
	
	NSArray *activityItems = @[data, titleItem, urlItem];
	NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePrint];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[]];
	activityViewController.excludedActivityTypes = excludedActivityTypes;
	
	[self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)markPhotoSeenIfNeessary: (PhotoItem *)photo {
    if (![photo isShowed]) {
        [appDelegate.showedSet addObject:photo.idString];
        subReddit.unshowedCount --;
    }
}

@end
