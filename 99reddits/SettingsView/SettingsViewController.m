//
//  SettingsViewController.m
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import "SettingsViewController.h"
#import "RedditsAppDelegate.h"


@interface SettingsViewController ()

- (IBAction)onDoneButton:(id)sender;
- (IBAction)onUpgradeForMOARButton:(id)sender;
- (IBAction)onRestoreUpgradeButton:(id)sender;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
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

	if (appDelegate.isPaid) {
		[buttonsView removeFromSuperview];
		CGRect frame = aboutView.frame;
		frame.origin.y -= 171;
		aboutView.frame = frame;
	}
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

- (IBAction)onUpgradeForMOARButton:(id)sender {
}

- (IBAction)onRestoreUpgradeButton:(id)sender {
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
			cell.detailTextLabel.text = @"2.0 PAID";
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
	int height = [[aboutWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
	height += 10;
	CGRect frame = aboutWebView.frame;
	frame.size.height = height;
	aboutWebView.frame = frame;
	
	aboutOutlineButton.frame = CGRectMake(10, 214, 300, height + 25);
	
	if (appDelegate.isPaid) {
		contentScrollView.contentSize = CGSizeMake(320, aboutOutlineButton.frame.origin.y + aboutOutlineButton.frame.size.height + 10);
	}
	else {
		contentScrollView.contentSize = CGSizeMake(320, aboutOutlineButton.frame.origin.y + aboutOutlineButton.frame.size.height + 10 + 171);
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}

@end
