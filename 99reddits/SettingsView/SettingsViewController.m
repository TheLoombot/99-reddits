//
//  SettingsViewController.m
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import "SettingsViewController.h"
#import "RedditsAppDelegate.h"
#import "UserDef.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>


@interface SettingsViewController ()

- (IBAction)onDoneButton:(id)sender;
- (IBAction)onUpgradeForMOARButton:(id)sender;
- (IBAction)onRestoreUpgradeButton:(id)sender;
- (IBAction)onEmailButton:(id)sender;
- (IBAction)onTweetButton:(id)sender;

- (void)refreshViews;

@end

@implementation SettingsViewController

@synthesize hud;

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
	[hud release];
	hud = nil;
	[imagesSeenString release];
	[titleString release];
	[imagesToNextTitleString release];
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
	
	[upgradeForMOARButton setBackgroundImage:[[UIImage imageNamed:@"UpgradeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[restoreUpdateButton setBackgroundImage:[[UIImage imageNamed:@"UpgradeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];

	aboutWebView.frame = CGRectMake(20, 229, 280, 100);
	[aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"]]]];
	
	int showedCount = [[appDelegate showedSet] count];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	imagesSeenString = [[formatter stringFromNumber:[NSNumber numberWithInteger:showedCount]] retain];
	int imagesSeenLevel = showedCount / 1000;
	if (imagesSeenLevel > 26)
		imagesSeenLevel = 26;
	NSString *key = [NSString stringWithFormat:@"%d", imagesSeenLevel * 1000 - 1];
	
	NSDictionary *titleDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Titles" ofType:@"plist"]];
	titleString = [[titleDictionary objectForKey:key] retain];
	
	imagesToNextTitleString = [[formatter stringFromNumber:[NSNumber numberWithInt:(imagesSeenLevel + 1) * 1000 - showedCount]] retain];
	
	[formatter release];

	contentTableView.backgroundColor = [UIColor clearColor];
	
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onDoneButton:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

// UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SETTINGS_VIEW_CELL";
	UITableViewCell *cell = [contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
	}
	
	int row = indexPath.row;
	if (row == 0) {
		cell.textLabel.text = @"Version";
		cell.detailTextLabel.textColor = [UIColor colorWithRed:80 / 255.0 green:114 / 255.0 blue:160 / 255.0 alpha:1.0];
		if (appDelegate.isPaid)
			cell.detailTextLabel.text = @"2.0 MOAR";
		else
			cell.detailTextLabel.text = @"2.0 FREE";
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
	[alertView release];
	
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
		[alertView release];
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
		[alertView release];
	}
}

- (void)refreshViews {
	int height = [[aboutWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
	height += 10;
	CGRect frame = aboutWebView.frame;
	frame.size.height = height;
	aboutWebView.frame = frame;
	
	aboutOutlineButton.frame = CGRectMake(10, 214, 300, height + 25);
	
	emailButton.frame = CGRectMake(10, height + 249, 300, 45);
	tweetButton.frame = CGRectMake(10, height + 304, 300, 45);
	
	if (appDelegate.isPaid) {
		[buttonsView removeFromSuperview];
		CGRect frame = aboutView.frame;
		frame.origin.y = 0;
		frame.size.height = height + 349;
		aboutView.frame = frame;
		
		if (!appDelegate.tweetEnabled) {
			[tweetButton removeFromSuperview];
			contentScrollView.contentSize = CGSizeMake(320, emailButton.frame.origin.y + emailButton.frame.size.height + 10);
		}
		else {
			contentScrollView.contentSize = CGSizeMake(320, tweetButton.frame.origin.y + tweetButton.frame.size.height + 10);
		}
	}
	else {
		CGRect frame = aboutView.frame;
		frame.origin.y = 171;
		frame.size.height = height + 349;
		aboutView.frame = frame;
		
		if (!appDelegate.tweetEnabled) {
			[tweetButton removeFromSuperview];
			contentScrollView.contentSize = CGSizeMake(320, emailButton.frame.origin.y + emailButton.frame.size.height + 181);
		}
		else {
			contentScrollView.contentSize = CGSizeMake(320, tweetButton.frame.origin.y + tweetButton.frame.size.height + 181);
		}
	}
	
	[contentTableView reloadData];
}

- (IBAction)onEmailButton:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		
		[mailComposeViewController setSubject:@"99 reddits feedback"];
		[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"99reddits@lensie.com"]];
		
		[self presentModalViewController:mailComposeViewController animated:YES];
		[mailComposeViewController release];
	}
}

- (IBAction)onTweetButton:(id)sender {
	TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
	
	if ([TWTweetComposeViewController canSendTweet]) {
		[tweetComposeViewController setInitialText:@"@99reddits"];
	}
	
	tweetComposeViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
		[tweetComposeViewController dismissModalViewControllerAnimated:YES];
	};
	
	[self presentModalViewController:tweetComposeViewController animated:YES];
	[tweetComposeViewController release];
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}

@end
