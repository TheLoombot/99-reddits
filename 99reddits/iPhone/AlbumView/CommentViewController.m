//
//  CommentViewController.m
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CommentViewController.h"
#import "NINetworkActivity.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

@synthesize urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	if (loading) {
		[webView stopLoading];
		NINetworkActivityTaskDidFinish();
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[leftItem setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[rightItem setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
	navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];

	navItem.titleView = titleView;
	titleLabel.text = @"Loading...";
	urlLabel.text = urlString;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

	NSArray *subviews = webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = NO;
	}
	[[[UIApplication sharedApplication].windows objectAtIndex:0] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButton:(id)sender {
	NSArray *subviews = webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = YES;
	}
	if (isIOS7Below)
		[[[UIApplication sharedApplication].windows objectAtIndex:0] setBackgroundColor:[UIColor blackColor]];
	else
		[[[UIApplication sharedApplication].windows objectAtIndex:0] setBackgroundColor:[UIColor whiteColor]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onShareButton:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy link", @"Open in Safari", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;

	if (buttonIndex == 0) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = urlString;
	}
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}
}

// UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)wv {
	loading = YES;
	NINetworkActivityTaskDidStart();
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	loading = NO;
	NINetworkActivityTaskDidFinish();
	titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
