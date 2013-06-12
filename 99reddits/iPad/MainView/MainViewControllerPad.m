//
//  MainViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright 2012 99 reddits. All rights reserved.
//

#import "MainViewControllerPad.h"
#import "RedditsAppDelegate.h"
#import "MainViewCellPad.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "AlbumViewControllerPad.h"
#import "RedditsViewControllerPad.h"
#import "SettingsViewControllerPad.h"
#import "UserDef.h"

#define THUMB_WIDTH			108
#define THUMB_HEIGHT		108

@interface MainViewControllerPad ()

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;

@end

@implementation MainViewControllerPad

@synthesize lastAddedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)releaseObjects {
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	NI_RELEASE_SAFELY(activeRequests);
	NI_RELEASE_SAFELY(thumbnailImageCache);
	NI_RELEASE_SAFELY(refreshQueue);
	NI_RELEASE_SAFELY(queue);
}

- (void)dealloc {
	[self releaseObjects];
	
	[settingsItem release];
	[editItem release];
	[doneItem release];
	[addItem release];
	[refreshControl release];
	[popoverController release];
	[super dealloc];
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

    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	subRedditsArray = appDelegate.subRedditsArray;
	
	refreshControl = [[UIRefreshControl alloc] init];
	refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
	[refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:refreshControl];

	[appDelegate setNavAppearance];

	self.title = @"99 reddits";
	
	self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:settingsItem, nil];
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editItem, addItem, nil];

	[[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
	
	refreshQueue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	refreshCount = 0;
	scale = [[UIScreen mainScreen] scale];
	
	if (appDelegate.firstRun) {
		[self reloadData];
	}
	else {
//		NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
//		if (currentTime - appDelegate.updatedTime > 300)
//			[self reloadData];
	}

	MainViewLayoutPad *mainViewLayout = [[[MainViewLayoutPad alloc] init] autorelease];
	self.collectionView.allowsSelection = YES;
	self.collectionView.allowsMultipleSelection = NO;
	self.collectionView.delaysContentTouches = NO;
	self.collectionView.canCancelContentTouches = YES;
	[self.collectionView registerClass:[MainViewCellPad class] forCellWithReuseIdentifier:@"MAINVIEWCELLPAD"];
	[self.collectionView setCollectionViewLayout:mainViewLayout];
	[mainViewLayout setUpGestureRecognizersOnCollectionView];

	lastAddedIndex = -1;
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
	for (SubRedditItem *subReddit in subRedditsArray) {
		[subReddit calUnshowedCount];
	}
	[self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	if (lastAddedIndex >= 0) {
		[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:lastAddedIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
		lastAddedIndex = -1;
	}
}

- (IBAction)onEditButton:(id)sender {
	self.editing = !self.editing;
	if (self.editing) {
		[refreshControl removeFromSuperview];

		settingsItem.enabled = NO;
		addItem.enabled = NO;
		
		self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:doneItem, addItem, nil];
	}
	else {
		[self.collectionView addSubview:refreshControl];

		settingsItem.enabled = YES;
		addItem.enabled = YES;

		self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editItem, addItem, nil];
	}
	
	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (IBAction)onAddButton:(id)sender {
	RedditsViewControllerPad *redditsViewController = [[RedditsViewControllerPad alloc] initWithNibName:@"RedditsViewControllerPad" bundle:nil];
	redditsViewController.mainViewController = self;
	UINavigationController *redditsNavigationController = [[CustomNavigationController alloc] initWithRootViewController:redditsViewController];
	redditsNavigationController.navigationBarHidden = YES;
	popoverController = [[PopoverController alloc] initWithContentViewController:redditsNavigationController];
	popoverController.popoverContentSize = CGSizeMake(540, 620);
	popoverController.delegate = self;
	[redditsNavigationController release];
	[redditsViewController release];

	[popoverController showPopover:YES];
}

// UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return subRedditsArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MainViewCellPad *cell = (MainViewCellPad *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MAINVIEWCELLPAD" forIndexPath:indexPath];
	cell.mainViewController = self;
	
	if (indexPath.row == 0) {
		cell.subReddit = appDelegate.favoritesItem;
		cell.nameLabel.text = appDelegate.favoritesItem.nameString;
		
		if (appDelegate.favoritesItem.photosArray.count == 0) {
			[cell setImage:[UIImage imageNamed:@"FavoritesIconPad.png"]];
		}
		else {
			NSString *urlString = [self cacheKeyForPhotoIndex:indexPath.row - 1];
			UIImage *image = [thumbnailImageCache objectWithName:urlString];
			if (image == nil) {
				[self requestImageFromSource:urlString photoIndex:indexPath.row - 1];
				[cell setImage:[UIImage imageNamed:@"FavoritesIconPad.png"]];
			}
			else {
				[cell setImage:image];
			}
		}
		
		[cell setTotalCount:appDelegate.favoritesItem.photosArray.count];
	}
	else {
		SubRedditItem *subReddit = [subRedditsArray objectAtIndex:indexPath.row - 1];
		cell.subReddit = subReddit;
		cell.nameLabel.text = subReddit.nameString;
		
		if (subReddit.photosArray.count == 0 || subReddit.loading) {
			[cell setImage:[UIImage imageNamed:@"DefaultPhotoPad.png"]];
		}
		else {
			NSString *urlString = [self cacheKeyForPhotoIndex:indexPath.row - 1];
			UIImage *image = [thumbnailImageCache objectWithName:urlString];
			if (image == nil) {
				[self requestImageFromSource:urlString photoIndex:indexPath.row - 1];
				[cell setImage:[UIImage imageNamed:@"DefaultPhotoPad.png"]];
			}
			else {
				[cell setImage:image];
			}
		}
		
		[cell setUnshowedCount:subReddit.unshowedCount totalCount:subReddit.photosArray.count loading:subReddit.loading];
	}

	return cell;
}

// MainViewLayoutPadDelegate
- (BOOL)isEditingForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout {
	return self.editing;
}

- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath willMoveToIndexPath:(NSIndexPath *)theToIndexPath {
	SubRedditItem *subReddit = [[subRedditsArray objectAtIndex:theFromIndexPath.row - 1] retain];
	[subRedditsArray removeObjectAtIndex:theFromIndexPath.row - 1];
	[subRedditsArray insertObject:subReddit atIndex:theToIndexPath.row - 1];
	[subReddit release];
	
	[appDelegate saveToDefaults];
}

- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout shouldBeginReorderingAtIndexPath:(NSIndexPath *)theIndexPath {
	if (!self.editing)
		return NO;
	
	if (theIndexPath.row == 0)
		return NO;
	
	return YES;
}

- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath shouldMoveToIndexPath:(NSIndexPath *)theToIndexPath {
	if (!self.editing)
		return NO;
	
	if (theFromIndexPath.row == 0 || theToIndexPath.row == 0)
		return NO;
	
	return YES;
}

- (void)reloadData {
	if (self.editing)
		return;
	
	if (subRedditsArray.count == 0)
		return;

	if (![appDelegate checkNetworkReachable:YES])
		return;
	
	if (refreshCount != 0)
		return;
	
	refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Refreshing..."] autorelease];
	[refreshControl beginRefreshing];
	
	editItem.enabled = NO;
	
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	[activeRequests removeAllObjects];
	
	refreshCount = 0;
	
	for (int i = 0; i < subRedditsArray.count; i ++) {
		SubRedditItem *subReddit = [subRedditsArray objectAtIndex:i];
		subReddit.loading = YES;
		
		refreshCount ++;
		
		NSURL *url = [NSURL URLWithString:subReddit.urlString];
		NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
		albumRequest.shouldAttemptPersistentConnection = NO;
		albumRequest.timeOutSeconds = 30;
		albumRequest.delegate = self;
		albumRequest.processorDelegate = (id)[self class];
		[refreshQueue addOperation:albumRequest];
	}
	
	[self.collectionView reloadData];
}

// ASIHTTPRequestDelegate
- (void)requestFinished:(NIProcessorHTTPRequest *)request {
	NSString *urlString = [[request originalURL] absoluteString];
	
	SubRedditItem *subReddit = nil;
	for (SubRedditItem *tempSubReddit in subRedditsArray) {
		if ([tempSubReddit.urlString isEqualToString:urlString]) {
			subReddit = tempSubReddit;
			break;
		}
	}
	
	if (subReddit == nil) {
		refreshCount --;
		if (refreshCount == 0) {
			refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
			[refreshControl endRefreshing];

			editItem.enabled = YES;
		}
		return;
	}
	
	subReddit.loading = NO;
	subReddit.unshowedCount = 0;
	
	NSMutableArray *tempPhotosArray = [[NSMutableArray alloc] init];
	[tempPhotosArray addObjectsFromArray:subReddit.photosArray];
	
	NSDictionary *dictionary = (NSDictionary *)request.processedObject;
	[subReddit.photosArray removeAllObjects];
	[subReddit.photosArray addObjectsFromArray:[dictionary objectForKey:@"photos"]];
	
	subReddit.afterString = [dictionary objectForKey:@"after"];
	
	[subReddit calUnshowedCount];
	
	[self.collectionView reloadData];
	
	[tempPhotosArray removeAllObjects];
	[tempPhotosArray release];
	
	refreshCount --;
	if (refreshCount == 0) {
		refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
		[refreshControl endRefreshing];
	
		editItem.enabled = YES;
		[appDelegate saveToDefaults];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *urlString = [[request originalURL] absoluteString];
	
	SubRedditItem *subReddit = nil;
	for (SubRedditItem *tempSubReddit in subRedditsArray) {
		if ([tempSubReddit.urlString isEqualToString:urlString]) {
			subReddit = tempSubReddit;
			break;
		}
	}
	
	if (subReddit == nil) {
		refreshCount --;
		if (refreshCount == 0) {
			refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
			[refreshControl endRefreshing];

			editItem.enabled = YES;
		}
		return;
	}
	
	subReddit.loading = NO;
	subReddit.unshowedCount = 0;
	[subReddit.photosArray removeAllObjects];
	
	[self.collectionView reloadData];
	
	refreshCount --;
	if (refreshCount == 0) {
		refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
		[refreshControl endRefreshing];

		editItem.enabled = YES;
	}
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
		if (!permalinkString)
			photo.permalinkString = @"";
		else if ([permalinkString hasPrefix:@"http"])
			photo.permalinkString = permalinkString;
		else
			photo.permalinkString = [NSString stringWithFormat:@"http://www.reddit.com%@", permalinkString];
		
		photo.titleString = [RedditsAppDelegate stringByRemoveHTML:[itemData objectForKey:@"title"]];
		photo.urlString = [RedditsAppDelegate getImageURL:[itemData objectForKey:@"url"]];
		
		NSString *thumbnailString = [itemData objectForKey:@"thumbnail"];
		
		// If the thumbnail string is empty or a default value, AND the URL is an imgur link,
        // then we go to imgur to get the thumbnail
		// Big Square   [160x160px]:  http://i.imgur.com/46dFab.jpg
        if ([photo.urlString hasPrefix:@"http://i.imgur.com/"] || [photo.urlString hasPrefix:@"http://imgur.com/"]) {
			NSString *lastComp = [photo.urlString lastPathComponent];
			photo.thumbnailString = [NSString stringWithFormat:@"http://i.imgur.com/%@b.png", [lastComp stringByDeletingPathExtension]];
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
		[photo release];
	}
	
	NSString *afterString = [data objectForKey:@"after"];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:photosArray, @"photos", afterString, @"after", nil];
	
	return dictionary;
}

- (void)addSubReddit:(SubRedditItem *)subReddit {
	if (![appDelegate checkNetworkReachable:YES])
		return;
	
	refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Refreshing..."] autorelease];
	[refreshControl beginRefreshing];

	editItem.enabled = NO;
	
	subReddit.loading = YES;
	
	refreshCount ++;
	
	NSURL *url = [NSURL URLWithString:subReddit.urlString];
	NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
	albumRequest.shouldAttemptPersistentConnection = NO;
	albumRequest.timeOutSeconds = 30;
	albumRequest.delegate = self;
	albumRequest.processorDelegate = (id)[self class];
	[refreshQueue addOperation:albumRequest];
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	if (photoIndex == -1) {
		if (appDelegate.favoritesItem.photosArray.count == 0)
			return @"";
		
		return [[appDelegate.favoritesItem.photosArray objectAtIndex:0] thumbnailString];
	}
	else {
		SubRedditItem *subReddit = [subRedditsArray objectAtIndex:photoIndex];
		if (subReddit.photosArray.count == 0)
			return @"";
		
		return [[subReddit.photosArray objectAtIndex:0] thumbnailString];
	}
}

- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex {
//	if (![appDelegate checkNetworkReachable:NO])
//		return;
	
	if (source.length == 0)
		return;
	
	if ([activeRequests containsObject:source]) {
		return;
	}
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.shouldAttemptPersistentConnection = NO;
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	
	NSString *photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	[readOp setCompletionBlock:^{
		UIImage *image = [UIImage imageWithData:[readOp responseData]];
		
		int index = -2;
		if (photoIndex == -1) {
			index = -1;
		}
		else {
			for (int i = 0; i < subRedditsArray.count; i ++) {
				NSString *keyString = [self cacheKeyForPhotoIndex:i];
				if ([keyString isEqualToString:photoIndexKey]) {
					index = i;
					break;
				}
			}
		}
		
		if (index != -2) {
			if (image && (subRedditsArray.count + 1 > photoIndex || photoIndex == -1)) {
				int x, y, w, h;
				float imgRatio = image.size.width / image.size.height;
				if (imgRatio < 1) {
					h = THUMB_HEIGHT;
					w = h * imgRatio;
					x = 0;
					y = 0;
				}
				else if (imgRatio > 1) {
					w = THUMB_WIDTH;
					h = w / imgRatio;
					x = 0;
					y = 0;
				}
				else {
					w = THUMB_WIDTH;
					h = THUMB_HEIGHT;
					x = 0.0;
					y = 0.0;
				}
				
				UIGraphicsBeginImageContext(CGSizeMake(w * scale, h * scale));
				CGRect rect = CGRectMake(x * scale, y * scale, w * scale, h * scale);
				[image drawInRect:rect];
				UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				[thumbnailImageCache storeObject:thumbImage withName:photoIndexKey];
				[self performSelectorOnMainThread:@selector(reloadCell:) withObject:[NSIndexPath indexPathForRow:index + 1 inSection:0] waitUntilDone:NO];
			}
		}
		
		[activeRequests removeObject:source];
	}];
	
	[readOp setFailedBlock:^{
		[activeRequests removeObject:source];
	}];
	
	
	[readOp setQueuePriority:NSOperationQueuePriorityNormal];
	
	[activeRequests addObject:source];
	[queue addOperation:readOp];
}

- (void)reloadCell:(NSIndexPath *)indexPath {
	[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (IBAction)onSettingsButton:(id)sender {
	SettingsViewControllerPad *settingsViewController = [[SettingsViewControllerPad alloc] initWithNibName:@"SettingsViewControllerPad" bundle:nil];
	settingsViewController.mainViewController = self;
	popoverController = [[PopoverController alloc] initWithContentViewController:settingsViewController];
	popoverController.popoverContentSize = CGSizeMake(540, 620);
	popoverController.delegate = self;
	[settingsViewController release];
	
	[popoverController showPopover:YES];
}

- (void)removeSubRedditOperations:(SubRedditItem *)subReddit {
	if (subReddit.photosArray.count > 0) {
		NSString *thumbnailString = [[subReddit.photosArray objectAtIndex:0] thumbnailString];
		for (ASIHTTPRequest *request in queue.operations) {
			if ([[request.originalURL absoluteString] isEqualToString:thumbnailString]) {
				[request clearDelegatesAndCancel];
				[activeRequests removeObject:thumbnailString];
				break;
			}
		}
	}
}

- (void)showSubReddit:(SubRedditItem *)subReddit {
	if (subReddit == appDelegate.favoritesItem) {
		if (appDelegate.favoritesItem.photosArray.count > 0) {
			AlbumViewControllerPad *albumViewController = [[AlbumViewControllerPad alloc] initWithNibName:@"AlbumViewControllerPad" bundle:nil];
			albumViewController.mainViewController = self;
			albumViewController.subReddit = appDelegate.favoritesItem;
			albumViewController.bFavorites = YES;
			[self.navigationController pushViewController:albumViewController animated:YES];
			[albumViewController release];
		}
	}
	else {
		if (subReddit.photosArray.count > 0 && !subReddit.loading) {
			AlbumViewControllerPad *albumViewController = [[AlbumViewControllerPad alloc] initWithNibName:@"AlbumViewControllerPad" bundle:nil];
			albumViewController.mainViewController = self;
			albumViewController.subReddit = subReddit;
			albumViewController.bFavorites = NO;
			[self.navigationController pushViewController:albumViewController animated:YES];
			[albumViewController release];
		}
	}
}

- (void)removeSubReddit:(SubRedditItem *)subReddit {
	if (subReddit == appDelegate.favoritesItem)
		return;

	if (![subRedditsArray containsObject:subReddit])
		return;
	
	int index = [subRedditsArray indexOfObject:subReddit];
	if (subReddit.photosArray.count > 0) {
		NSString *thumbnailString = [[subReddit.photosArray objectAtIndex:0] thumbnailString];
		for (ASIHTTPRequest *request in queue.operations) {
			if ([[request.originalURL absoluteString] isEqualToString:thumbnailString]) {
				[request clearDelegatesAndCancel];
				[activeRequests removeObject:thumbnailString];
				break;
			}
		}
	}
	
	subReddit.subscribe = NO;
	[appDelegate.nameStringsSet removeObject:[subReddit.nameString lowercaseString]];
	[subRedditsArray removeObject:subReddit];
	[self.collectionView performBatchUpdates:^() { [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index + 1 inSection:0]]]; } completion:nil];

	[appDelegate saveToDefaults];
}

// PopoverControllerDelegate
- (void)popoverControllerDidDismissed:(PopoverController *)controller {
	[popoverController release];
	popoverController = nil;
}

- (void)dismissPopover {
	[popoverController dismissPopover:YES];
}

@end
