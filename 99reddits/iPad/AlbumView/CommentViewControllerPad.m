//
//  CommentViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CommentViewControllerPad.h"

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
	[urlString release];
	[navItem release];
	[shareItem release];
	[webView release];
	[actionSheet release];
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	navItem.title = urlString;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
		[actionSheet release];
		actionSheet = nil;
	}

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onShareButton:(id)sender {
	if (actionSheet) {
		[actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
		[actionSheet release];
		actionSheet = nil;
	}
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy link", @"Open in Safari", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromBarButtonItem:shareItem animated:YES];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;

	if (buttonIndex == 0) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = urlString;
	}
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}

	[actionSheet release];
	actionSheet = nil;
}

@end
