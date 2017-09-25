//
//  CommentViewController.m
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CommentViewController.h"
#import "NINetworkActivity.h"

@interface CommentViewController () <UIWebViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *leftItem;
@property (weak, nonatomic) IBOutlet UIToolbar *rightItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

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
		[self.webView stopLoading];
		NINetworkActivityTaskDidFinish();
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;

	self.navigationItem.leftBarButtonItem = self.closeItem;
	self.navigationItem.rightBarButtonItem = self.shareItem;
	
	self.webView.opaque = NO;
	self.webView.backgroundColor = [UIColor clearColor];

	self.title = @"Loading...";
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

	NSArray *subviews = self.webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = NO;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButton:(id)sender {
	NSArray *subviews = self.webView.subviews;
	for (UIView *subview in subviews) {
		subview.clipsToBounds = YES;
	}
	[[[UIApplication sharedApplication].windows objectAtIndex:0] setBackgroundColor:[UIColor blackColor]];
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
	self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

//MARK - IBAction methods

- (IBAction)previousBarButtonItemTapped:(UIBarButtonItem *)sender {

  if ([self.webView canGoBack]) {
    [self.webView goBack];
  }
}

- (IBAction)nextBarButtonItemTapped:(UIBarButtonItem *)sender {

  if ([self.webView canGoForward]) {
    [self.webView goForward];
  }
}

@end
