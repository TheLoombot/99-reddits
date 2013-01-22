//
//  AlbumViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "AlbumViewControllerPad.h"
#import "SubRedditItem.h"
#import "AlbumViewCellPad.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "PhotoViewControllerPad.h"
#import "RedditsAppDelegate.h"
#import "MainViewControllerPad.h"
#import "UserDef.h"

#define THUMB_WIDTH			108
#define THUMB_HEIGHT		108


@interface AlbumViewControllerPad ()

- (void)loadThumbnails;
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;
- (void)refreshSubReddit;

@end

@implementation AlbumViewControllerPad

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
	NI_RELEASE_SAFELY(currentSubReddit);
}

- (void)dealloc {
	[self releaseObjects];
	
	[subReddit release];
	[mainViewController release];
	[currentPhotosArray release];
	
	[contentTableView release];
	[footerView release];
	[moarButton release];
	[moarWaitingView release];
	[tabBar release];
	[hotItem release];
	[newItem release];
	[controversialItem release];
	[topItem release];
	[showTypeSegmentedControl release];
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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = subReddit.nameString;
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	
	refreshQueue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	scale = [[UIScreen mainScreen] scale];
	
	if (bFavorites) {
		[tabBar removeFromSuperview];
		contentTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
	else {
		contentTableView.tableFooterView = footerView;
	}
	
	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
	[moarButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateDisabled];
	moarWaitingView.hidden = YES;
	
	[showTypeSegmentedControl setBackgroundImage:[[UIImage imageNamed:@"BarButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[showTypeSegmentedControl setBackgroundImage:[[UIImage imageNamed:@"BarButtonBackHighlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	
	[appDelegate checkNetworkReachable:YES];
	
	tabBar.selectedItem = hotItem;
	currentItem = hotItem;
	
	currentPhotosArray = [[NSMutableArray alloc] init];
	if (bFavorites) {
		currentSubReddit = [subReddit retain];
	}
	else {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = subReddit.urlString;
		[currentSubReddit.photosArray addObjectsFromArray:subReddit.photosArray];
		currentSubReddit.afterString = subReddit.afterString;
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:showTypeSegmentedControl] autorelease];
	}
	
	contentTableView.delaysContentTouches = NO;
	contentTableView.canCancelContentTouches = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	if (showTypeSegmentedControl.selectedSegmentIndex == 1) {
		[self refreshSubReddit];
	}
	else {
		[contentTableView reloadData];
	}
	
	bFromSubview = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (!bFromSubview) {
		[self releaseObjects];
	}
}

- (void)onSelectPhoto:(PhotoItem *)photo {
	bFromSubview = YES;
	
	if (bFavorites) {
		PhotoViewControllerPad *photoViewController = [[PhotoViewControllerPad alloc] initWithNibName:@"PhotoViewControllerPad" bundle:nil];
		photoViewController.bFavorites = bFavorites;
		photoViewController.subReddit = currentSubReddit;
		photoViewController.index = [currentSubReddit.photosArray indexOfObject:photo];
		[self.navigationController pushViewController:photoViewController animated:YES];
		[photoViewController release];
	}
	else {
		SubRedditItem *photoSubReddit = [[[SubRedditItem alloc] init] autorelease];
		photoSubReddit.nameString = currentSubReddit.nameString;
		photoSubReddit.urlString = currentSubReddit.urlString;
		[photoSubReddit.photosArray addObjectsFromArray:currentPhotosArray];
		photoSubReddit.afterString = currentSubReddit.afterString;
		
		PhotoViewControllerPad *photoViewController = [[PhotoViewControllerPad alloc] initWithNibName:@"PhotoViewControllerPad" bundle:nil];
		photoViewController.bFavorites = bFavorites;
		photoViewController.subReddit = photoSubReddit;
		photoViewController.index = [currentPhotosArray indexOfObject:photo];
		[self.navigationController pushViewController:photoViewController animated:YES];
		[photoViewController release];
	}
}

// UITableViewDelegate, UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	[currentPhotosArray removeAllObjects];
	if (showTypeSegmentedControl.selectedSegmentIndex == 0) {
		[currentPhotosArray addObjectsFromArray:currentSubReddit.photosArray];
	}
	else {
		for (PhotoItem *photo in currentSubReddit.photosArray) {
			if (![photo isShowed]) {
				[currentPhotosArray addObject:photo];
			}
		}
	}
	
	if (!bFavorites) {
		BOOL bShowTypeControlEnabled = NO;
		for (PhotoItem *photo in currentSubReddit.photosArray) {
			if (![photo isShowed]) {
				bShowTypeControlEnabled = YES;
			}
		}
		
		if (bShowTypeControlEnabled) {
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:showTypeSegmentedControl] autorelease];
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
		else {
			self.navigationItem.rightBarButtonItem.enabled = NO;
			
			if (showTypeSegmentedControl.selectedSegmentIndex == 1) {
				showTypeSegmentedControl.selectedSegmentIndex = 0;
				[self performSelector:@selector(refreshSubReddit) withObject:nil afterDelay:0.1];
				
				return 0;
			}
		}
	}

	int count = currentPhotosArray.count;
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	int rowCount = count / colCount + (count % colCount ? 1 : 0);
	
	[self loadThumbnails];

	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ALBUM_VIEW_CELL";
	AlbumViewCellPad *cell = (AlbumViewCellPad *)[contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[AlbumViewCellPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	cell.albumViewController = self;
	cell.photosArray = currentPhotosArray;
	cell.bFavorites = bFavorites;
	cell.row = indexPath.row;
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;

	for (int i = 0; i < colCount; i ++) {
		int index = indexPath.row * colCount + i;
		if (index < currentPhotosArray.count) {
			NSString *urlString = [self cacheKeyForPhotoIndex:index];
			UIImage *image = [thumbnailImageCache objectWithName:urlString];
			if (image == nil) {
				[self requestImageFromSource:urlString photoIndex:index];
				[cell setImage:[UIImage imageNamed:@"DefaultPhotoPad.png"] index:index % colCount];
			}
			else {
				[cell setImage:image index:index % colCount];
			}
		}
		else {
			break;
		}
	}
	
	return cell;
}

- (void)loadThumbnails {
	for (int i = 0; i < currentPhotosArray.count; i ++) {
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
	
	NSNumber *identifierKey = [NSNumber numberWithInt:photoIndex];
	if ([activeRequests containsObject:identifierKey]) {
		return;
	}
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	readOp.tag = photoIndex;
	
	NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	[readOp setCompletionBlock:^{
		UIImage *image = [UIImage imageWithData:[readOp responseData]];
		
		if (image && currentPhotosArray.count > photoIndex) {
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
			
			int colCount = PORT_COL_COUNT;
			if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
				colCount = LAND_COL_COUNT;

			[thumbnailImageCache storeObject:thumbImage withName:photoIndexKey];
			AlbumViewCellPad *cell = (AlbumViewCellPad *)[contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoIndex / colCount inSection:0]];
			[cell setImage:thumbImage index:photoIndex % colCount];
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
	[subReddit release];
	subReddit = [_subReddit retain];
}

- (IBAction)onMOARButton:(id)sender {
	if (!appDelegate.isPaid) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
		[alertView show];
		[alertView release];
		
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
		[alertView show];
		[alertView release];
		
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
	
	[currentSubReddit release];
	
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
			
			[contentTableView reloadData];
		}
		else {
			moarButton.enabled = YES;
			[moarButton setTitle:@"MOAR" forState:UIControlStateNormal];
			moarWaitingView.hidden = YES;
			
			[currentSubReddit.photosArray addObjectsFromArray:subReddit.photosArray];
			[contentTableView reloadData];
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
		
		[contentTableView reloadData];
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
		
		[contentTableView reloadData];
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
		
		[contentTableView reloadData];
	}
}

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		[self.navigationController popViewControllerAnimated:NO];
		[mainViewController onSettingsButton:nil];
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
	
	[contentTableView reloadData];
	
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

- (IBAction)onShowType:(id)sender {
	[self refreshSubReddit];
}

- (void)refreshSubReddit {
	for (ASIHTTPRequest *request in refreshQueue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	[activeRequests removeAllObjects];
	
	[contentTableView reloadData];
}

@end
