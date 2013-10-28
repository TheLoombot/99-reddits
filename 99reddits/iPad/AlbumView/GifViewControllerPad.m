//
//  GifViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "GifViewControllerPad.h"
#import "PhotoViewPad.h"

@interface GifViewControllerPad ()

- (void)resizeWebview:(BOOL)portrait;

@end

@implementation GifViewControllerPad

@synthesize gifData = _gifData;
@synthesize width;
@synthesize height;
@synthesize photoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	if (isIOS7Below)
		self.view.backgroundColor = [UIColor blackColor];
	else
		self.view.backgroundColor = [UIColor whiteColor];
	
	_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
	_tapGesture.cancelsTouchesInView = NO;
	_tapGesture.enabled = YES;
	[overlayView addGestureRecognizer:_tapGesture];
	
	[self resizeWebview:UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[self resizeWebview:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
	[UIView commitAnimations];
}

- (void)resizeWebview:(BOOL)portrait {
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	
	int screenWidth, screenHeight;
	if (portrait) {
		screenWidth = screenSize.width;
		screenHeight = screenSize.height;
	}
	else {
		screenWidth = screenSize.height;
		screenHeight = screenSize.width;
	}
	
	float imgRatio = (float)width / (float)height;
	float screenRatio = (float)screenWidth / (float)screenHeight;
	
	float x, y, w, h;
	if (width < screenWidth && height < screenHeight) {
		webView.scalesPageToFit = NO;
		w = width;
		h = height;
		x = floorf((screenWidth - w) / 2.0);
		y = floorf((screenHeight - h) / 2.0);
	}
	else {
		webView.scalesPageToFit = YES;
		if (imgRatio < screenRatio) {
			h = screenHeight;
			w = floorf(h * imgRatio);
			x = floorf((screenWidth - w) / 2.0);
			y = 0;
		}
		else if (imgRatio > screenRatio) {
			w = screenWidth;
			h = floorf(w / imgRatio);
			x = 0;
			y = floorf((screenHeight - h) / 2.0);
		}
		else {
			w = screenWidth;
			h = screenHeight;
			x = 0;
			y = 0;
		}
	}
	
	webView.frame = CGRectMake(x, y, w, h);
}

- (void)viewWillAppear:(BOOL)animated {
	hidden = [UIApplication sharedApplication].statusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	[self resizeWebview:UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)];
	[webView loadData:_gifData MIMEType:@"image/tiff" textEncodingName:@"utf-8" baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

- (void)setGifData:(NSData *)gifData {
	_gifData = gifData;
}

- (void)didTap {
	[photoView dismissPopover];
}

@end
