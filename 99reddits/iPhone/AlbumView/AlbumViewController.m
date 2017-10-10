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
#import "PhotoViewController.h"
#import "MainViewController.h"
#import "UserDef.h"
#import "AlbumViewLayout.h"
#import "_9reddits-Swift.h"

#define THUMB_WIDTH			75
#define THUMB_HEIGHT		75

@interface AlbumViewController ()

@property (nonatomic, strong) NSOperationQueue *refreshQueue;

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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

    self.refreshQueue = [[NSOperationQueue alloc] init];
    self.refreshQueue.maxConcurrentOperationCount = 5;

    self.title = subReddit.nameString;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:subReddit.nameString style:UIBarButtonItemStylePlain target:nil action:nil];

    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }

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

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSubReddit:YES];
}

- (void)onSelectPhoto:(PhotoItem *)photo {
    if (bFavorites) {
        PhotoViewController *photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
        photoViewController.bFavorites = bFavorites;
        photoViewController.subReddit = currentSubReddit;
        photoViewController.photoIndexToDisplay = [currentSubReddit.photosArray indexOfObject:photo];
        [self.navigationController pushViewController:photoViewController animated:YES];
    }
    else {
        SubRedditItem *photoSubReddit = [[SubRedditItem alloc] init];
        photoSubReddit.nameString = currentSubReddit.nameString;
        photoSubReddit.urlString = currentSubReddit.urlString;
        [photoSubReddit.photosArray addObjectsFromArray:currentPhotosArray];
        photoSubReddit.afterString = currentSubReddit.afterString;

        PhotoViewController *viewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
        viewController.bFavorites = bFavorites;
        viewController.subReddit = photoSubReddit;
        viewController.photoIndexToDisplay = [currentPhotosArray indexOfObject:photo];
        [self.navigationController pushViewController:viewController animated:YES];
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

    PhotoItem *photo = currentPhotosArray[indexPath.item];

    AlbumViewCell *cell = (AlbumViewCell *)[contentCollectionView dequeueReusableCellWithReuseIdentifier:@"ALBUM_VIEW_CELL" forIndexPath:indexPath];
    cell.albumViewController = self;
    cell.insideFavoritesAlbum = bFavorites;
    cell.photo = photo;

    [ImageLoader loadWithUrlString:photo.thumbnailString into:cell.imageView];

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

- (void)setSubReddit:(SubRedditItem *)_subReddit {
    subReddit = _subReddit;
}

- (IBAction)onMOARButton:(id)sender {

    bMOARLoading = YES;

    moarButton.enabled = NO;
    [moarButton setTitle:@"" forState:UIControlStateNormal];
    moarWaitingView.hidden = NO;

    if (currentSubReddit.afterString == (NSString *)[NSNull null] || currentSubReddit.afterString.length == 0) {
        NSURL *url = [NSURL URLWithString:currentSubReddit.urlString];
        NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
        albumRequest.timeOutSeconds = 30;
        albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
        albumRequest.delegate = self;
        albumRequest.processorDelegate = (id)[self class];
        [self.refreshQueue addOperation:albumRequest];
    }
    else {
        NSURL *url = [NSURL URLWithString:[currentSubReddit.urlString stringByAppendingFormat:@"&after=%@", currentSubReddit.afterString]];
        NIProcessorHTTPRequest* albumRequest = [NIJSONKitProcessorHTTPRequest requestWithURL:url usingCache:nil];
        albumRequest.timeOutSeconds = 30;
        albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
        albumRequest.delegate = self;
        albumRequest.processorDelegate = (id)[self class];
        [self.refreshQueue addOperation:albumRequest];
    }
}

// UITabBarDelegate
- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
    if (currentItem == item) {
        return;
    }

    bMOARLoading = NO;

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
            albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
            albumRequest.processorDelegate = (id)[self class];
            [self.refreshQueue addOperation:albumRequest];

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
        albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
        albumRequest.processorDelegate = (id)[self class];
        [self.refreshQueue addOperation:albumRequest];

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
        albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
        albumRequest.processorDelegate = (id)[self class];
        [self.refreshQueue addOperation:albumRequest];

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
        albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
        albumRequest.delegate = self;
        albumRequest.processorDelegate = (id)[self class];
        [self.refreshQueue addOperation:albumRequest];

        [self refreshSubReddit:YES];
    }
}

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 101) {
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
            albumRequest.userAgentString = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B72";
            albumRequest.delegate = self;
            albumRequest.processorDelegate = (id)[self class];
            [self.refreshQueue addOperation:albumRequest];
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
            photo.permalinkString = [NSString stringWithFormat:@"https://www.reddit.com%@.compact", permalinkString];

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

    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }

    if (buttonIndex == 0) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.mailComposeDelegate = self;

            [mailComposeViewController setSubject:@"99 reddits Favorites Export"];
            [mailComposeViewController setMessageBody:[appDelegate getFavoritesEmailString] isHTML:YES];

            [self presentViewController:mailComposeViewController animated:YES completion:nil];
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
