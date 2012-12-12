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

- (void)reloadData;
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;

@end

@implementation MainViewControllerPad

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
	
	[contentTableView release];
	[leftItemsBar release];
	[rightItemsBar release];
	[refreshItem release];
	[settingsItem release];
	[spaceItem release];
	[editItem release];
	[doneItem release];
	[addItem release];
	[popoverController release];
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	subRedditsArray = appDelegate.subRedditsArray;
	
	[appDelegate setNavAppearance];

	self.title = @"99 reddits";
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftItemsBar] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightItemsBar] autorelease];

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
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self releaseObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[contentTableView reloadData];
    return YES;
}

- (BOOL)shouldAutorotate {
	[contentTableView reloadData];
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	for (SubRedditItem *subReddit in subRedditsArray) {
		[subReddit calUnshowedCount];
	}
	[contentTableView reloadData];
}

- (IBAction)onEditButton:(id)sender {
	self.editing = !self.editing;
	contentTableView.editing = self.editing;
	if (self.editing) {
		refreshItem.enabled = NO;
		settingsItem.enabled = NO;
		addItem.enabled = NO;
		
		[rightItemsBar setItems:[NSArray arrayWithObjects:spaceItem, doneItem, addItem, nil] animated:YES];
	}
	else {
		refreshItem.enabled = YES;
		settingsItem.enabled = YES;
		addItem.enabled = YES;
		
		[rightItemsBar setItems:[NSArray arrayWithObjects:spaceItem, editItem, addItem, nil] animated:YES];
	}
}

- (IBAction)onRefreshButton:(id)sender {
	if (subRedditsArray.count == 0)
		return;
	[self reloadData];
}

- (IBAction)onAddButton:(id)sender {
	RedditsViewControllerPad *redditsViewController = [[RedditsViewControllerPad alloc] initWithNibName:@"RedditsViewControllerPad" bundle:nil];
	redditsViewController.mainViewController = self;
	UINavigationController *redditsNavigationController = [[UINavigationController alloc] initWithRootViewController:redditsViewController];
	redditsNavigationController.navigationBarHidden = YES;
	popoverController = [[PopoverController alloc] initWithContentViewController:redditsNavigationController];
	popoverController.popoverContentSize = CGSizeMake(540, 620);
	popoverController.delegate = self;
	[redditsNavigationController release];
	[redditsViewController release];

	[popoverController showPopover:YES];
}

// UITableViewDatasource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int count = subRedditsArray.count + 1;
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	int rowCount = count / colCount + (count % colCount ? 1 : 0);
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifer = @"MAINVIEWCELLPAD";
	MainViewCellPad *cell = (MainViewCellPad *)[contentTableView dequeueReusableCellWithIdentifier:identifer];
	if (cell == nil) {
		cell = [[[MainViewCellPad alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer] autorelease];
		cell.mainViewController = self;
		cell.subRedditsArray = subRedditsArray;
	}
	
	cell.row = indexPath.row;
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	for (int i = 0; i < colCount; i ++) {
		int index = colCount * indexPath.row + i - 1;
		if (index == -1) {
			if (appDelegate.favoritesItem.photosArray.count == 0) {
				[cell setImage:[UIImage imageNamed:@"FavoritesIconPad.png"] index:i];
			}
			else {
				NSString *urlString = [self cacheKeyForPhotoIndex:index];
				UIImage *image = [thumbnailImageCache objectWithName:urlString];
				if (image == nil) {
					[self requestImageFromSource:urlString photoIndex:index];
					[cell setImage:[UIImage imageNamed:@"FavoritesIconPad.png"] index:i];
				}
				else {
					[cell setImage:image index:i];
				}
			}
		}
		else {
			if (index < subRedditsArray.count) {
				SubRedditItem *subReddit = [subRedditsArray objectAtIndex:index];
				
				if (subReddit.photosArray.count == 0 || subReddit.loading) {
					[cell setImage:[UIImage imageNamed:@"DefaultPhotoPad.png"] index:i];
				}
				else {
					NSString *urlString = [self cacheKeyForPhotoIndex:index];
					UIImage *image = [thumbnailImageCache objectWithName:urlString];
					if (image == nil) {
						[self requestImageFromSource:urlString photoIndex:index];
						[cell setImage:[UIImage imageNamed:@"DefaultPhotoPad.png"] index:i];
					}
					else {
						[cell setImage:image index:i];
					}
				}
			}
		}
	}

	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (void)reloadData {
	if (![appDelegate checkNetworkReachable:YES])
		return;
	
	refreshItem.enabled = NO;
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
	
	[contentTableView reloadData];
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
			refreshItem.enabled = YES;
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
	
	[contentTableView reloadData];
	
	[tempPhotosArray removeAllObjects];
	[tempPhotosArray release];
	
	refreshCount --;
	if (refreshCount == 0) {
		refreshItem.enabled = YES;
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
			refreshItem.enabled = YES;
			editItem.enabled = YES;
		}
		return;
	}
	
	subReddit.loading = NO;
	subReddit.unshowedCount = 0;
	[subReddit.photosArray removeAllObjects];
	
	[contentTableView reloadData];
	
	refreshCount --;
	if (refreshCount == 0) {
		refreshItem.enabled = YES;
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
			photo.permalinkString = [NSString stringWithFormat:@"http://www.reddit.com%@.compact", permalinkString];
		
		photo.titleString = [RedditsAppDelegate stringByRemoveHTML:[itemData objectForKey:@"title"]];
		photo.urlString = [RedditsAppDelegate getImageURL:[itemData objectForKey:@"url"]];
		
		NSString *thumbnailString = [itemData objectForKey:@"thumbnail"];
		
		// If the thumbnail string is empty or a default value, AND the URL is an imgur link,
        // then we go to imgur to get the thumbnail
        // Thumb        [160px max]:  http://i.imgur.com/46dFat.jpg
        if ((thumbnailString.length == 0 || [thumbnailString isEqualToString:@"default"] || [thumbnailString isEqualToString:@"nsfw"]) &&
			([photo.urlString hasPrefix:@"http://i.imgur.com/"] || [photo.urlString hasPrefix:@"http://imgur.com/"])
            ) {
			NSString *lastComp = [photo.urlString lastPathComponent];
			NSRange range = [lastComp rangeOfString:@"."];
			if (range.location != NSNotFound) {
				lastComp = [lastComp substringToIndex:range.location-1];
				photo.thumbnailString = [NSString stringWithFormat:@"http://i.imgur.com/%@t.png", lastComp];
			}
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
	
	refreshItem.enabled = NO;
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
				
				int colCount = PORT_COL_COUNT;
				if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
					colCount = LAND_COL_COUNT;
				int row = (index + 1) / colCount;
				int col = (index + 1) % colCount;
				MainViewCellPad *cell = (MainViewCellPad *)[contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
				[cell setImage:thumbImage index:col];
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

- (void)showSubRedditAtIndex:(int)index {
	if (index == -1) {
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
		SubRedditItem *subReddit = [subRedditsArray objectAtIndex:index];
		
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

- (void)removeSubRedditAtIndex:(int)index {
	SubRedditItem *subReddit = [subRedditsArray objectAtIndex:index];
	if (subReddit.photosArray.count > 0) {
		NSString *thumbnailString = [[subReddit.photosArray objectAtIndex:0] thumbnailString];
		for (ASIHTTPRequest *request in queue.operations) {
			if ([[request.originalURL absoluteString] isEqualToString:thumbnailString]) {
				[request clearDelegatesAndCancel];
				[activeRequests removeObject:thumbnailString];
				break;
			}
		}
		[subReddit removeAllCaches];
	}
	
	subReddit.subscribe = NO;
	[appDelegate.manualSubRedditsArray removeObject:subReddit];
	[subRedditsArray removeObject:subReddit];
	[appDelegate saveToDefaults];
	
	[contentTableView reloadData];
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
