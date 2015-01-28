//
//  AlbumViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AlbumViewController.h"
#import "SubRedditItem.h"
#import "AlbumViewCell.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "PhotoViewController.h"
#import "MainViewController.h"
#import "UserDef.h"
#import "AlbumViewLayout.h"

#define THUMB_WIDTH			75
#define THUMB_HEIGHT		75

@interface AlbumViewController ()

- (void)loadThumbnails;
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;
- (void)refreshSubReddit:(BOOL)reload;

@end

@implementation AlbumViewController

@synthesize mainViewController;
@synthesize subReddit;
@synthesize bFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[self releaseCaches];
}

- (void)releaseCaches {
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	activeRequests = nil;
	thumbnailImageCache = nil;
	refreshQueue = nil;
	queue = nil;
	currentSubReddit = nil;
}

- (void)didReceiveMemoryWarning {
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	[activeRequests removeAllObjects];
	[thumbnailImageCache reduceMemoryUsage];
	
	[contentCollectionView reloadData];
 
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = subReddit.nameString;
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:subReddit.nameString style:UIBarButtonItemStylePlain target:nil action:nil];
	
	refreshQueue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];

	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	if (bFavorites) {
		[tabBar removeFromSuperview];
		contentCollectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}

	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonHighlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateHighlighted];
	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateDisabled];
	moarWaitingView.hidden = YES;
	
	[appDelegate checkNetworkReachable:YES];
	
	tabBar.selectedItem = hotItem;
	currentItem = hotItem;
	
	currentPhotosArray = [[NSMutableArray alloc] init];
	if (bFavorites) {
		currentSubReddit = subReddit;

		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton:)];
	}
	else {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = subReddit.urlString;
		[currentSubReddit.photosArray addObjectsFromArray:subReddit.photosArray];
		currentSubReddit.afterString = subReddit.afterString;

		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:showTypeSegmentedControl];
	}
	
	AlbumViewLayout *albumViewLayout = [[AlbumViewLayout alloc] init];
	if (!bFavorites) {
		albumViewLayout.footerReferenceSize = CGSizeMake(screenWidth, 60);
	}
	
	CGRect frame = footerView.frame;
	frame.size.width = screenWidth;
	footerView.frame = frame;

	contentCollectionView.allowsSelection = YES;
	contentCollectionView.allowsMultipleSelection = NO;
	contentCollectionView.delaysContentTouches = NO;
	contentCollectionView.canCancelContentTouches = YES;
	[contentCollectionView registerClass:[AlbumViewCell class] forCellWithReuseIdentifier:@"ALBUM_VIEW_CELL"];
	if (!bFavorites)
		[contentCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ALBUM_FOOTER_VIEW"];
	[contentCollectionView setCollectionViewLayout:albumViewLayout];

	if (!bFavorites)
		showTypeSegmentedControl.selectedSegmentIndex = 1;

	initialized = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshSubReddit:YES];

	bFromSubview = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		[self releaseCaches];
	}
}

- (void)onSelectPhoto:(PhotoItem *)photo {
	bFromSubview = YES;
	
	if (bFavorites) {
		PhotoViewController *photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
		photoViewController.bFavorites = bFavorites;
		photoViewController.subReddit = currentSubReddit;
		photoViewController.index = [currentSubReddit.photosArray indexOfObject:photo];
		[self.navigationController pushViewController:photoViewController animated:YES];
	}
	else {
		SubRedditItem *photoSubReddit = [[SubRedditItem alloc] init];
		photoSubReddit.nameString = currentSubReddit.nameString;
		photoSubReddit.urlString = currentSubReddit.urlString;
		[photoSubReddit.photosArray addObjectsFromArray:currentPhotosArray];
		photoSubReddit.afterString = currentSubReddit.afterString;
		
		PhotoViewController *photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
		photoViewController.bFavorites = bFavorites;
		photoViewController.subReddit = photoSubReddit;
		photoViewController.index = [currentPhotosArray indexOfObject:photo];
		[self.navigationController pushViewController:photoViewController animated:YES];
	}
}

// UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	[collectionView.collectionViewLayout invalidateLayout];
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return currentPhotosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	AlbumViewCell *cell = (AlbumViewCell *)[contentCollectionView dequeueReusableCellWithReuseIdentifier:@"ALBUM_VIEW_CELL" forIndexPath:indexPath];
	cell.albumViewController = self;
	cell.bFavorites = bFavorites;
	cell.photo = [currentPhotosArray objectAtIndex:indexPath.item];

	NSString *urlString = [self cacheKeyForPhotoIndex:indexPath.item];
	UIImage *image = [thumbnailImageCache objectWithName:urlString];
	if (image == nil) {
		[self requestImageFromSource:urlString photoIndex:indexPath.item];
		[cell setThumbImage:nil animated:NO];
	}
	else {
		[cell setThumbImage:image animated:NO];
	}

	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionReusableView *collectionFooterView = [contentCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ALBUM_FOOTER_VIEW" forIndexPath:indexPath];
	if (footerView.superview != collectionFooterView) {
		[footerView removeFromSuperview];
		footerView.center = CGPointMake(collectionFooterView.frame.size.width / 2, collectionFooterView.frame.size.height / 2);
		[collectionFooterView addSubview:footerView];
	}

	return collectionFooterView;
}

- (void)loadThumbnails {
	for (NSInteger i = 0; i < currentPhotosArray.count; i ++) {
		NSString *photoIndexKey = [self cacheKeyForPhotoIndex:i];
		if (![thumbnailImageCache containsObjectWithName:photoIndexKey]) {
			[self requestImageFromSource:[[currentPhotosArray objectAtIndex:i] thumbnailString] photoIndex:i];
		}
	}
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	return [[currentPhotosArray objectAtIndex:photoIndex] thumbnailString];
}

- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex {
//	if (![appDelegate checkNetworkReachable:NO])
//		return;

	if (source.length == 0)
		return;
	
	NSNumber *identifierKey = [NSNumber numberWithInteger:photoIndex];
	if ([activeRequests containsObject:identifierKey]) {
		return;
	}
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest __weak *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	readOp.tag = photoIndex;
	
	NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	[readOp setCompletionBlock:^{
		UIImage *image = [UIImage imageWithData:[readOp responseData]];
		
		if (image && currentPhotosArray.count > photoIndex) {
			NSInteger x, y, w, h;
			if (image.size.width > THUMB_WIDTH * 2 && image.size.height > THUMB_HEIGHT * 2) {
				float imgRatio = image.size.width / image.size.height;
				if (imgRatio < 1) {
					w = THUMB_WIDTH;
					h = w / imgRatio;
					x = 0;
					y = (THUMB_HEIGHT - h) / 2;
				}
				else if (imgRatio > 1) {
					h = THUMB_HEIGHT;
					w = h * imgRatio;
					x = (THUMB_WIDTH - w) / 2;
					y = 0;
				}
				else {
					w = THUMB_WIDTH;
					h = THUMB_HEIGHT;
					x = 0.0;
					y = 0.0;
				}
			}
			else {
				w = image.size.width;
				h = image.size.height;
				x = (THUMB_WIDTH - w) / 2;
				y = (THUMB_HEIGHT - h) / 2;
			}

			UIGraphicsBeginImageContextWithOptions(CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT), NO, screenScale);
			CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
			CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, THUMB_WIDTH, THUMB_HEIGHT));
			CGRect rect = CGRectMake(x, y, w, h);
			[image drawInRect:rect];
			UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			[thumbnailImageCache storeObject:thumbImage withName:photoIndexKey];
			AlbumViewCell *cell = (AlbumViewCell *)[contentCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:photoIndex inSection:0]];
			[cell setThumbImage:thumbImage animated:YES];
		}
		
		[activeRequests removeObject:identifierKey];
	}];
	
	[readOp setFailedBlock:^{
		[activeRequests removeObject:identifierKey];
	}];
	
	
	[readOp setQueuePriority:NSOperationQueuePriorityNormal];
	
	[activeRequests addObject:identifierKey];
	[queue addOperation:readOp];
}

- (void)setSubReddit:(SubRedditItem *)_subReddit {
	subReddit = _subReddit;
}

- (IBAction)onMOARButton:(id)sender {
	if (!appDelegate.isPaid) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
		alertView.tag = 100;
		[alertView show];
		
		return;
	}
	
	bMOARLoading = YES;
	
	moarButton.enabled = NO;
	[moarButton setTitle:@"" forState:UIControlStateNormal];
	moarWaitingView.hidden = NO;
	
	if (currentSubReddit.afterString == (NSString *)[NSNull null] || currentSubReddit.afterString.length == 0) {
		NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];
	}
	else {
		NSURL *url = [NSURL URLWithString:[currentSubReddit.urlString stringByAppendingFormat:@"&after=%@", currentSubReddit.afterString]];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];
	}
}

// UITabBarDelegate
- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
	if (currentItem == item)
		return;
	
	if (!appDelegate.isPaid) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
		alertView.tag = 100;
		[alertView show];
		
		tabBar.selectedItem = hotItem;
		
		return;
	}

	bMOARLoading = NO;
	
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}

	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}

	[activeRequests removeAllObjects];

	
	moarButton.enabled = NO;
	[moarButton setTitle:@"" forState:UIControlStateNormal];
	moarWaitingView.hidden = NO;
	
	currentItem = item;
	if (currentItem == hotItem) {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = subReddit.urlString;
		currentSubReddit.afterString = subReddit.afterString;

		if (currentSubReddit.afterString == (NSString *)[NSNull null] || currentSubReddit.afterString.length == 0) {
			NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
			NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
			albumRequest.timeOutSeconds = 30;
			albumRequest.delegate = self;
			albumRequest.processorDelegate = (id)[self class];
			[refreshQueue addOperation:albumRequest];

			[self refreshSubReddit:YES];
		}
		else {
			moarButton.enabled = YES;
			[moarButton setTitle:@"MOAR" forState:UIControlStateNormal];
			moarWaitingView.hidden = YES;

			[currentSubReddit.photosArray addObjectsFromArray:subReddit.photosArray];

			[self refreshSubReddit:YES];
		}
	}
	else if (currentItem == newItem) {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = [NSString stringWithFormat:NEW_SUBREDDIT_FORMAT, subReddit.nameString];
		currentSubReddit.afterString = @"";
		
		NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];

		[self refreshSubReddit:YES];
	}
	else if (currentItem == controversialItem) {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = [NSString stringWithFormat:CONTROVERSIAL_SUBREDDIT_FORMAT, subReddit.nameString];
		currentSubReddit.afterString = @"";
		
		NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];
		
		[self refreshSubReddit:YES];
	}
	else {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = [NSString stringWithFormat:TOP_SUBREDDIT_FORMAT, subReddit.nameString];
		currentSubReddit.afterString = @"";
		
		NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];
		
		[self refreshSubReddit:YES];
	}
}

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 100) {
		if (buttonIndex != alertView.cancelButtonIndex) {
			[self.navigationController popViewControllerAnimated:NO];
			[mainViewController onSettingsButton:nil];
		}
	}
	else if (alertView.tag == 101) {
		if (buttonIndex != alertView.cancelButtonIndex) {
			[appDelegate clearFavorites];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

// ASIHTTPRequestDelegate
- (void)requestFinished:(NIProcessorHTTPRequest *)request {
	moarButton.enabled = YES;
	[moarButton setTitle:@"MOAR" forState:UIControlStateNormal];
	moarWaitingView.hidden = YES;

	NSDictionary *dictionary = (NSDictionary *)request.processedObject;
	
	if (currentSubReddit.afterString == (NSString *)[NSNull null] || currentSubReddit.afterString.length == 0) {
		[currentSubReddit.photosArray removeAllObjects];
		[currentSubReddit.photosArray addObjectsFromArray:[dictionary objectForKey:@"photos"]];
		currentSubReddit.afterString = [dictionary objectForKey:@"after"];
		
		if (currentItem == hotItem) {
			[subReddit.photosArray removeAllObjects];
			[subReddit.photosArray addObjectsFromArray:currentSubReddit.photosArray];
			subReddit.afterString = currentSubReddit.afterString;
		}
		
		if (bMOARLoading) {
			NSURL *url = [NSURL URLWithString:[currentSubReddit.urlString stringByAppendingFormat:@"&after=%@", currentSubReddit.afterString]];
			NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
			albumRequest.timeOutSeconds = 30;
			albumRequest.delegate = self;
			albumRequest.processorDelegate = (id)[self class];
			[refreshQueue addOperation:albumRequest];
		}
	}
	else {
		[currentSubReddit.photosArray addObjectsFromArray:[dictionary objectForKey:@"photos"]];
		currentSubReddit.afterString = [dictionary objectForKey:@"after"];
	}
	
	[self refreshSubReddit:NO];

	bMOARLoading = NO;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	moarButton.enabled = YES;
	[moarButton setTitle:@"MOAR" forState:UIControlStateNormal];
	moarWaitingView.hidden = YES;
	
	bMOARLoading = NO;
}

// NIProcessorDelegate
+ (id)processor:(id)processor processObject:(id)object error:(NSError **)processingError {
	if (![object isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	NSDictionary *data = [object objectForKey:@"data"];
	if (data == nil)
		return nil;
	
	NSDictionary *array = [data objectForKey:@"children"];
	if (array == nil)
		return nil;
	
	NSMutableArray *photosArray = [NSMutableArray arrayWithCapacity:array.count];
	for (NSDictionary *item in array) {
		NSDictionary *itemData = [item objectForKey:@"data"];
		
		PhotoItem *photo = [[PhotoItem alloc] init];
		photo.idString = [itemData objectForKey:@"id"];
		photo.nameString = [itemData objectForKey:@"name"];
		
		NSString *permalinkString = [itemData objectForKey:@"permalink"];
		if (permalinkString.length == 0)
			photo.permalinkString = @"";
		else if ([permalinkString hasPrefix:@"http"])
			photo.permalinkString = permalinkString;
		else
			photo.permalinkString = [NSString stringWithFormat:@"http://www.reddit.com%@.compact", permalinkString];
		
		photo.titleString = [RedditsAppDelegate stringByRemoveHTML:[itemData objectForKey:@"title"]];
		photo.urlString = [RedditsAppDelegate getImageURL:[itemData objectForKey:@"url"]];
		
		NSString *thumbnailString = [itemData objectForKey:@"thumbnail"];
		
		// If the thumbnail string is empty or a default value, AND the URL is an imgur link,
        // then we go to imgur to get the thumbnail
        // Small square [90x90px]:    http://i.imgur.com/46dFas.jpg
        if ([photo.urlString hasPrefix:@"http://i.imgur.com/"] || [photo.urlString hasPrefix:@"http://imgur.com/"]) {
			NSString *lastComp = [photo.urlString lastPathComponent];
			photo.thumbnailString = [NSString stringWithFormat:@"http://i.imgur.com/%@s.png", [lastComp stringByDeletingPathExtension]];
		}
		else {
			photo.thumbnailString = [RedditsAppDelegate getImageURL:thumbnailString];
		}
        
		NSString *extension = [[photo.urlString pathExtension] lowercaseString];
		if (extension.length != 0 && ([extension isEqualToString:@"jpg"] || 
									  [extension isEqualToString:@"jpeg"] || 
									  [extension isEqualToString:@"gif"] || 
									  [extension isEqualToString:@"png"] || 
									  [extension isEqualToString:@"tiff"] || 
									  [extension isEqualToString:@"tif"] || 
									  [extension isEqualToString:@"bmp"]
									  )) {
            
			// However if the thumbnail is empty or a default value and NOT an imgur link,
            // we instead use the FULL image URL as the thumbnail...
            // Do we need this?  Does this result in us downloading photos twice if we don't have
            // an otherwise usable thumbnail?  (Aman 20-Dec-2011)
            if ((photo.thumbnailString.length == 0) ||
                [photo.thumbnailString isEqualToString:@"nsfw"] ||
                [photo.thumbnailString isEqualToString:@"default"])
				photo.thumbnailString = photo.urlString;
			
            [photosArray addObject:photo];
		}
	}
	
	NSString *afterString = [data objectForKey:@"after"];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:photosArray, @"photos", afterString, @"after", nil];
	
	return dictionary;
}

- (IBAction)onShowType:(id)sender {
	if (!self.navigationItem.rightBarButtonItem.enabled)
		return;

	[self refreshSubReddit:NO];
}

- (void)refreshSubReddit:(BOOL)reload {
	NSMutableArray *newPhotosArray = [NSMutableArray array];

	if (showTypeSegmentedControl.selectedSegmentIndex == 0) {
		[newPhotosArray addObjectsFromArray:currentSubReddit.photosArray];
	}
	else {
		for (PhotoItem *photo in currentSubReddit.photosArray) {
			if (![photo isShowed]) {
				[newPhotosArray addObject:photo];
			}
		}
	}

	if (self.bFavorites) {
		self.title = subReddit.nameString;
	}
	else {
		NSInteger unshowedCount = 0;
		for (PhotoItem *photo in currentSubReddit.photosArray) {
			if (![photo isShowed]) {
				unshowedCount ++;
			}
		}

		if (unshowedCount > 0) {
			self.title = [NSString stringWithFormat:@"%@ (%ld)", subReddit.nameString, (long)unshowedCount];

			showTypeSegmentedControl.userInteractionEnabled = YES;
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:showTypeSegmentedControl];
		}
		else {
			self.title = subReddit.nameString;

			self.navigationItem.rightBarButtonItem.enabled = NO;
			showTypeSegmentedControl.userInteractionEnabled = NO;

			if (showTypeSegmentedControl.selectedSegmentIndex == 1) {
				showTypeSegmentedControl.selectedSegmentIndex = 0;

				[newPhotosArray addObjectsFromArray:currentSubReddit.photosArray];
			}
		}
	}

	if (!initialized || reload) {
		initialized = YES;
		[currentPhotosArray removeAllObjects];
		[currentPhotosArray addObjectsFromArray:newPhotosArray];
		[self loadThumbnails];
		[contentCollectionView reloadData];
	}
	else {
		NSMutableArray *deleteItemsArray = [NSMutableArray array];
		for (NSInteger i = 0; i < currentPhotosArray.count; i ++) {
			PhotoItem *photo = [currentPhotosArray objectAtIndex:i];
			if (![newPhotosArray containsObject:photo]) {
				[deleteItemsArray addObject:[NSIndexPath indexPathForItem:i inSection:0]];
			}
		}

		NSMutableArray *insertItemsArray = [NSMutableArray array];
		for (NSInteger i = 0; i < newPhotosArray.count; i ++) {
			PhotoItem *photo = [newPhotosArray objectAtIndex:i];
			if (![currentPhotosArray containsObject:photo]) {
				[insertItemsArray addObject:[NSIndexPath indexPathForItem:i inSection:0]];
			}
		}

		if (deleteItemsArray.count == 0 && insertItemsArray.count == 0)
			return;

		[currentPhotosArray removeAllObjects];
		[currentPhotosArray addObjectsFromArray:newPhotosArray];
		[self loadThumbnails];

		self.view.userInteractionEnabled = NO;
		footerView.alpha = 0.0;
		[contentCollectionView
		 performBatchUpdates:^(void) {
			 if (deleteItemsArray.count > 0) {
				 [contentCollectionView deleteItemsAtIndexPaths:deleteItemsArray];
			 }
			 if (insertItemsArray.count > 0) {
				 [contentCollectionView insertItemsAtIndexPaths:insertItemsArray];
			 }
		 }
		 completion:^(BOOL finished) {
			 self.view.userInteractionEnabled = YES;
			 footerView.alpha = 1.0;
		 }];
	}
}

- (void)onActionButton:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:@"Email Favorites"
									 otherButtonTitles:@"Clear Favorites", nil];
	actionSheet.destructiveButtonIndex = 1;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;

	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;

	if (buttonIndex == 0) {
		if (!appDelegate.isPaid) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
			alertView.tag = 100;
			[alertView show];
		}
		else {
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				mailComposeViewController.mailComposeDelegate = self;

				[mailComposeViewController setSubject:@"99 reddits Favorites Export"];
				[mailComposeViewController setMessageBody:[appDelegate getFavoritesEmailString] isHTML:YES];

				bFromSubview = YES;
				[self presentViewController:mailComposeViewController animated:YES completion:nil];
			}
		}
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear ALL your favorites?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		alertView.tag = 101;
		[alertView show];
	}
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

@end
