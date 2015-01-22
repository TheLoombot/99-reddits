//
//  SettingsViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "SettingsViewControllerPad.h"
#import "RedditsAppDelegate.h"
#import "UserDef.h"
#import <Accounts/Accounts.h>
#import "ASIDownloadCache.h"
#import "MainViewControllerPad.h"
#import <Social/Social.h>
#import "Appirater.h"

@interface SettingsViewControllerPad ()

- (IBAction)onUpgradeForMOARButton:(id)sender;
- (IBAction)onRestoreUpgradeButton:(id)sender;
- (IBAction)onClearButton:(id)sender;
- (IBAction)onEmailButton:(id)sender;
- (IBAction)onTweetButton:(id)sender;
- (IBAction)onRateAppButton:(id)sender;

- (void)refreshViews;

- (UIColor *)groupTableViewBackgroundColor;

@end

@implementation SettingsViewControllerPad

@synthesize mainViewController;
@synthesize hud;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseRestoreFinishedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseRestoreFailedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Settings";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton:)];
	if (isIOS7Below) {
		self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	}
	else {
		[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
	}

	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	for (id subview in aboutWebView.subviews)
		if ([[subview class] isSubclassOfClass:[UIScrollView class]])
			((UIScrollView *)subview).bounces = NO;

	if (isIOS7Below)
		self.view.backgroundColor = [self groupTableViewBackgroundColor];
	else
		self.view.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:244 / 255.0 alpha:1.0];
	
	[upgradeForMOARButton setBackgroundImage:[[UIImage imageNamed:@"UpgradeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[restoreUpdateButton setBackgroundImage:[[UIImage imageNamed:@"UpgradeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[clearButton setBackgroundImage:[[UIImage imageNamed:@"ClearButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal];

    NSInteger width = self.view.bounds.size.width;
	aboutWebView.frame = CGRectMake((width - 430) / 2, 335, 430, 100);
	[aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"]]]];
	
	NSInteger showedCount = [[appDelegate showedSet] count];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	imagesSeenString = [formatter stringFromNumber:[NSNumber numberWithInteger:showedCount]];
	NSInteger imagesSeenLevel = showedCount / 1000;
	if (imagesSeenLevel > 80)
		imagesSeenLevel = 80;
	NSString *key = [NSString stringWithFormat:@"%ld", (long)(imagesSeenLevel * 1000 - 1)];
	
	NSDictionary *titleDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Titles" ofType:@"plist"]];
	titleString = [titleDictionary objectForKey:key];

	if (showedCount < 80000) {
        imagesToNextTitleString = [formatter stringFromNumber:[NSNumber numberWithInteger:(imagesSeenLevel + 1) * 1000 - showedCount]];
    }
	else {
        imagesToNextTitleString = @"You win!";
    }
	
	[aboutOutlineButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
	[emailButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[emailButton setBackgroundImage:[[UIImage imageNamed:@"ButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
	[tweetButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[tweetButton setBackgroundImage:[[UIImage imageNamed:@"ButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
	[rateAppButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[rateAppButton setBackgroundImage:[[UIImage imageNamed:@"ButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];

	if (!isIOS7Below) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
		self.extendedLayoutIncludesOpaqueBars = NO;
		self.automaticallyAdjustsScrollViewInsets = NO;
	}

	UIImageView *infoBackView = [[UIImageView alloc] initWithFrame:contentTableView.frame];
	infoBackView.image = [[UIImage imageNamed:@"SettingsInfoBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	[aboutView insertSubview:infoBackView belowSubview:contentTableView];

	contentTableView.backgroundColor = [UIColor clearColor];
	contentTableView.backgroundView = nil;

	[self refreshViews];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseRestoreFinished:) name:kProductPurchaseRestoreFinishedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseRestoreFailed:) name:kProductPurchaseRestoreFailedNotification object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width, contentScrollView.contentSize.height);
    return YES;
}

- (BOOL)shouldAutorotate {
	contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width, contentScrollView.contentSize.height);
	return YES;
}

- (void)onDoneButton:(id)sender {
	[mainViewController dismissPopover];
}

// UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SETTINGS_VIEW_CELL";
	UITableViewCell *cell = [contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
		cell.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
	}
	
	NSInteger row = indexPath.row;
	if (row == 0) {
		cell.textLabel.text = @"Version";
		cell.detailTextLabel.textColor = [UIColor colorWithRed:80 / 255.0 green:114 / 255.0 blue:160 / 255.0 alpha:1.0];
		if (appDelegate.isPaid)
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ MOAR", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
		else
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ FREE", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	}
	else if (row == 1) {
		cell.textLabel.text = @"Images Seen";
		cell.detailTextLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:92 / 255.0 blue:0 / 255.0 alpha:1.0];
		cell.detailTextLabel.text = imagesSeenString;
	}
	else if (row == 2) {
		cell.textLabel.text = @"Title";
		cell.detailTextLabel.textColor = [UIColor colorWithRed:80 / 255.0 green:114 / 255.0 blue:160 / 255.0 alpha:1.0];
		cell.detailTextLabel.text = titleString;
	}
	else {
		cell.textLabel.text = @"Images to Next Title";
		cell.detailTextLabel.textColor = [UIColor colorWithRed:80 / 255.0 green:114 / 255.0 blue:160 / 255.0 alpha:1.0];
		cell.detailTextLabel.text = imagesToNextTitleString;
	}
	
	return cell;
}

// UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self refreshViews];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		if ([[request URL].absoluteString isEqualToString:@"itms-apps://itunes.com/apps/lensie/99reddits"])
			[Appirater rateApp];
		else
			[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}

- (IBAction)onUpgradeForMOARButton:(id)sender {
	[PurchaseManager sharedManager].delegate = self;
	[PurchaseManager sharedManager].productIdentifiers = [NSSet setWithObject:PRODUCT_ID];
	[[PurchaseManager sharedManager] requestProducts];
	
	self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = @"Loading ...";
	[self performSelector:@selector(timeout:) withObject:nil afterDelay:300];
}

- (IBAction)onRestoreUpgradeButton:(id)sender {
	[PurchaseManager sharedManager].delegate = self;
	[[PurchaseManager sharedManager] restorePurchases];
	
	self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = @"Restoring ...";
	[self performSelector:@selector(timeout:) withObject:nil afterDelay:300];
}

- (void)dismissHUD:(id)arg {
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	self.hud = nil;
}

- (void)timeout:(id)arg {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Timeout" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	
	[PurchaseManager sharedManager].delegate = nil;
	
	[self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:0.01];
}

- (void)productsLoaded:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	
	if ([PurchaseManager sharedManager].products.count > 0) {
		SKProduct *product = [[PurchaseManager sharedManager].products objectAtIndex:0];
		[[PurchaseManager sharedManager] buyProduct:product];
		
		self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		hud.labelText = @"Buying ...";
		[self performSelector:@selector(timeout:) withObject:nil afterDelay:300];
	}
	else {
		[PurchaseManager sharedManager].delegate = nil;
	}
}

- (void)productPurchased:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	[PurchaseManager sharedManager].delegate = nil;
	
	NSString *productId = (NSString *)notification.object;
	if ([productId isEqualToString:PRODUCT_ID]) {
		appDelegate.isPaid = YES;
	}
	
	[self refreshViews];
}

- (void)productPurchaseFailed:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	[PurchaseManager sharedManager].delegate = nil;
	
    SKPaymentTransaction *transaction = (SKPaymentTransaction *)notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
    }
}

- (void)productPurchaseRestoreFinished:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	[PurchaseManager sharedManager].delegate = nil;
	
	[self refreshViews];
}

- (void)productPurchaseRestoreFailed:(NSNotification *)notification {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
	[PurchaseManager sharedManager].delegate = nil;
	
	[self refreshViews];
	
	NSError *error = (NSError *)notification.object;
	if (error.code != SKErrorPaymentCancelled) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[(NSError *)notification.object localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)refreshViews {
	NSInteger width = self.view.bounds.size.width;

	NSInteger height = [[aboutWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
	height += 10;
	CGRect frame = aboutWebView.frame;
	frame.size.height = height;
	aboutWebView.frame = frame;
	
	aboutOutlineButton.frame = CGRectMake((width - 480) / 2, 318, 480, height + 25);
	
	emailButton.frame = CGRectMake((width - 480) / 2, height + 354, 480, 45);
	tweetButton.frame = CGRectMake((width - 480) / 2, height + 409, 480, 45);
	rateAppButton.frame = CGRectMake((width - 480) / 2, height + 464, 480, 45);
	
	if (appDelegate.isPaid) {
		[buttonsView removeFromSuperview];
		CGRect frame = aboutView.frame;
		frame.origin.y = 20;
		frame.size.height = height + 529;
		aboutView.frame = frame;
		
		contentScrollView.contentSize = CGSizeMake(width, rateAppButton.frame.origin.y + rateAppButton.frame.size.height + 50);
	}
	else {
		CGRect frame = aboutView.frame;
		frame.origin.y = 191;
		frame.size.height = height + 529;
		aboutView.frame = frame;
		
		contentScrollView.contentSize = CGSizeMake(width, rateAppButton.frame.origin.y + rateAppButton.frame.size.height + 221);
	}
	
	[contentTableView reloadData];
}

- (IBAction)onEmailButton:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		UIDevice *currentDevice = [UIDevice currentDevice];
		
		NSString *contentString = [NSString stringWithFormat:@"\n\n\n---\n99 reddits v%@\n%@ / iOS %@",
								   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
								   currentDevice.name,
								   currentDevice.systemVersion];
		
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		
		[mailComposeViewController setSubject:@"99 reddits feedback"];
		[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"99reddits@lensie.com"]];
		[mailComposeViewController setMessageBody:contentString isHTML:NO];
		
		[popoverController.ownerWindow.rootViewController presentViewController:mailComposeViewController animated:YES completion:nil];
	}
}

- (IBAction)onTweetButton:(id)sender {
	SLComposeViewController __weak *tweetComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[tweetComposeViewController setInitialText:@"@99reddits "];
	
	tweetComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
		[tweetComposeViewController dismissViewControllerAnimated:YES completion:nil];
	};
	
	[popoverController.ownerWindow.rootViewController presentViewController:tweetComposeViewController animated:YES completion:nil];
}

- (IBAction)onRateAppButton:(id)sender {
	[Appirater rateApp];
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClearButton:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear the Cache" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromRect:clearButton.frame inView:aboutView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex != buttonIndex) {
		self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		hud.labelText = @"Clearing...";
		
		[self performSelector:@selector(clearCaches) withObject:nil afterDelay:0.01];
	}
}

- (void)clearCaches {
//	[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	NSString *cachePath = [[[ASIDownloadCache sharedCache] storagePath] stringByAppendingPathComponent:@"PermanentStore"];
	[[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
	[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
	[self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:0.01];
}

- (UIColor *)groupTableViewBackgroundColor {
	UIImage *tableViewBackgroundImage = nil;
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(7.f, 1.f), NO, 0.0);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed:185/255.f green:192/255.f blue:202/255.f alpha:1.f] setFill];
	CGContextFillRect(c, CGRectMake(0, 0, 4, 1));
	[[UIColor colorWithRed:185/255.f green:193/255.f blue:200/255.f alpha:1.f] setFill];
	CGContextFillRect(c, CGRectMake(4, 0, 1, 1));
	[[UIColor colorWithRed:192/255.f green:200/255.f blue:207/255.f alpha:1.f] setFill];
	CGContextFillRect(c, CGRectMake(5, 0, 2, 1));
	tableViewBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [UIColor colorWithPatternImage:tableViewBackgroundImage];
}

@end
