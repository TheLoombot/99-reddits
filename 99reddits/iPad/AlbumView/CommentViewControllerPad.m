//
//  CommentViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CommentViewControllerPad.h"
#import "NINetworkActivity.h"

@interface CommentViewControllerPad ()

@end

@implementation CommentViewControllerPad

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

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;

	self.navigationItem.leftBarButtonItem = closeItem;
	self.navigationItem.rightBarButtonItem = shareItem;
	
	webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];

	self.title = @"Loading...";
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

	NSArray *subviews = webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = NO;
	}

	actionSheetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onActionSheetTapGesture:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
		actionSheet = nil;
	}

	NSArray *subviews = webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = YES;
	}
	[[[UIApplication sharedApplication].windows objectAtIndex:0] setBackgroundColor:[UIColor blackColor]];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onShareButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
		actionSheet = nil;
	}

	[self.view addGestureRecognizer:actionSheetTapGesture];
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy link", @"Open in Safari", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.view removeGestureRecognizer:actionSheetTapGesture];

	if (actionSheet == nil)
		return;

	if (buttonIndex == actionSheet.cancelButtonIndex) {
		actionSheet = nil;
		return;
	}

	if (buttonIndex == 0) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = urlString;
	}
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}

	actionSheet = nil;
}

// UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)wv {
	loading = YES;
	NINetworkActivityTaskDidStart();
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	loading = NO;
	NINetworkActivityTaskDidFinish();
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)onActionSheetTapGesture:(UITapGestureRecognizer *)gesture {
	[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
}

@end
