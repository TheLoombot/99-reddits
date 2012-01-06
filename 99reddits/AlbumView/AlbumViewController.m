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
#import "SettingsViewController.h"


#define THUMB_WIDTH			75
#define THUMB_HEIGHT		75


@interface AlbumViewController ()

- (void)loadThumbnails;
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;
- (void)requestImageFromSource:(NSString *)source photoIndex:(NSInteger)photoIndex;

@end

@implementation AlbumViewController

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
	for (ASIHTTPRequest *request in queue.operations) {
		request.delegate = nil;
	}
	[queue cancelAllOperations];
	
	NI_RELEASE_SAFELY(activeRequests);
	NI_RELEASE_SAFELY(thumbnailImageCache);
	NI_RELEASE_SAFELY(queue);
}

- (void)dealloc {
	[self releaseObjects];
	
	for (UITableViewCell *cell in cellArray) {
		int retainCount = [cell retainCount];
		while (retainCount > 1) {
			[cell release];
			retainCount = [cell retainCount];
		}
	}
	[cellArray release];
	[subReddit release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = subReddit.nameString;
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	
	cellArray = [[NSMutableArray alloc] init];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	[self loadThumbnails];
	
	contentTableView.tableFooterView = footerView;
	
	[appDelegate checkNetworkReachable:YES];
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
	if (!bFromSubview) {
		[self releaseObjects];
	}
}

- (void)onSelectPhoto:(PhotoItem *)photo {
	bFromSubview = YES;
	
	PhotoViewController *photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
	photoViewController.bFavorites = bFavorites;
	photoViewController.subReddit = subReddit;
	photoViewController.index = [subReddit.photosArray indexOfObject:photo];
	[self.navigationController pushViewController:photoViewController animated:YES];
	[photoViewController release];
}

// UITableViewDelegate, UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return subReddit.photosArray.count / 4 + (subReddit.photosArray.count % 4 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ALBUM_VIEW_CELL";
	AlbumViewCell *cell = (AlbumViewCell *)[contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[AlbumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[cellArray addObject:cell];
		[cell release];
	}
	
	cell.albumViewController = self;
	cell.photosArray = subReddit.photosArray;
	cell.bFavorites = bFavorites;
	cell.row = indexPath.row;
	
	for (int i = 0; i < 4; i ++) {
		int index = indexPath.row * 4 + i;
		if (index < subReddit.photosArray.count) {
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
	for (int i = 0; i < subReddit.photosArray.count; i ++) {
		NSString *photoIndexKey = [self cacheKeyForPhotoIndex:i];
		if (![thumbnailImageCache containsObjectWithName:photoIndexKey]) {
			[self requestImageFromSource:[[subReddit.photosArray objectAtIndex:i] thumbnailString] photoIndex:i];
		}
	}
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
	return [[subReddit.photosArray objectAtIndex:photoIndex] thumbnailString];
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

		if (image) {
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
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
	[alertView show];
	[alertView release];
}

// UITabBarDelegate
- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
	tabBar.selectedItem = nil;
	if (!appDelegate.isPaid) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a paid feature. It's cheap." message:nil delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Buy", nil];
		[alertView show];
		[alertView release];
		return;
	}
}

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
		[self presentModalViewController:settingsViewController animated:YES];
		[settingsViewController release];
	}
}

@end
