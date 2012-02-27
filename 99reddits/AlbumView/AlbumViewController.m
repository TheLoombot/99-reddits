//
//  AlbumViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewController.h"
#import "SubRedditItem.h"
#import "AlbumViewCell.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "AlbumViewController.h"
#import "PhotoViewController.h"
#import "RedditsAppDelegate.h"
#import "MainViewController.h"
#import "UserDef.h"


#define THUMB_WIDTH			75
#define THUMB_HEIGHT		75


@interface AlbumViewController ()

- (void)loadThumbnails;
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;

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
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = subReddit.nameString;
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	
	refreshQueue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];

	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	[self loadThumbnails];
	
	if (bFavorites) {
		[tabBar removeFromSuperview];
		contentTableView.frame = CGRectMake(0, 0, 320, 460);
	}
	else {
		contentTableView.tableFooterView = footerView;
	}
	
	moarWaitingView.hidden = YES;
	
	[appDelegate checkNetworkReachable:YES];
	
	tabBar.selectedItem = hotItem;
	currentItem = hotItem;
	
	if (bFavorites) {
		currentSubReddit = [subReddit retain];
	}
	else {
		currentSubReddit = [[SubRedditItem alloc] init];
		currentSubReddit.nameString = subReddit.nameString;
		currentSubReddit.urlString = subReddit.urlString;
		[currentSubReddit.photosArray addObjectsFromArray:subReddit.photosArray];
		currentSubReddit.afterString = subReddit.afterString;
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self releaseObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
	[contentTableView reloadData];
	
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
	
	PhotoViewController *photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
	photoViewController.bFavorites = bFavorites;
	photoViewController.subReddit = currentSubReddit;
	photoViewController.index = [currentSubReddit.photosArray indexOfObject:photo];
	[self.navigationController pushViewController:photoViewController animated:YES];
	[photoViewController release];
}

// UITableViewDelegate, UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return currentSubReddit.photosArray.count / 4 + (currentSubReddit.photosArray.count % 4 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ALBUM_VIEW_CELL";
	AlbumViewCell *cell = (AlbumViewCell *)[contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[AlbumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	cell.albumViewController = self;
	cell.photosArray = currentSubReddit.photosArray;
	cell.bFavorites = bFavorites;
	cell.row = indexPath.row;
	
	for (int i = 0; i < 4; i ++) {
		int index = indexPath.row * 4 + i;
		if (index < currentSubReddit.photosArray.count) {
			NSString *urlString = [self cacheKeyForPhotoIndex:index];
			UIImage *image = [thumbnailImageCache objectWithName:urlString];
			if (image == nil) {
				[self requestImageFromSource:urlString photoIndex:index];
				[cell setImage:[UIImage imageNamed:@"DefaultPhoto.png"] index:index % 4];
			}
			else {
				[cell setImage:image index:index % 4];
			}
		}
		else {
			break;
		}
	}
	
	return cell;
}

- (void)loadThumbnails {
	for (int i = 0; i < currentSubReddit.photosArray.count; i ++) {
		NSString *photoIndexKey = [self cacheKeyForPhotoIndex:i];
		if (![thumbnailImageCache containsObjectWithName:photoIndexKey]) {
			[self requestImageFromSource:[[currentSubReddit.photosArray objectAtIndex:i] thumbnailString] photoIndex:i];
		}
	}
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	return [[currentSubReddit.photosArray objectAtIndex:photoIndex] thumbnailString];
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
		
		if (image && subReddit.photosArray.count > photoIndex) {
			int x, y, w, h;
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
			
			UIGraphicsBeginImageContext(CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT));
			CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
			CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, THUMB_WIDTH, THUMB_HEIGHT));
			CGRect rect = CGRectMake(x, y, w, h);
			[image drawInRect:rect];
			UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			[thumbnailImageCache storeObject:thumbImage withName:photoIndexKey];
			AlbumViewCell *cell = (AlbumViewCell *)[contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoIndex / 4 inSection:0]];
			[cell setImage:thumbImage index:photoIndex % 4];
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
			[self loadThumbnails];
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
	
	[self loadThumbnails];
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
        // Small square [90x90px]:    http://i.imgur.com/46dFas.jpg
        if ((thumbnailString.length == 0 || [thumbnailString isEqualToString:@"default"] || [thumbnailString isEqualToString:@"nsfw"]) &&
			([photo.urlString hasPrefix:@"http://i.imgur.com/"] || [photo.urlString hasPrefix:@"http://imgur.com/"]) 
            ) {
			NSString *lastComp = [photo.urlString lastPathComponent];
			NSRange range = [lastComp rangeOfString:@"."];
			if (range.location != NSNotFound) {
				lastComp = [lastComp substringToIndex:range.location-1];
				photo.thumbnailString = [NSString stringWithFormat:@"http://i.imgur.com/%@s.png", lastComp];
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

@end
