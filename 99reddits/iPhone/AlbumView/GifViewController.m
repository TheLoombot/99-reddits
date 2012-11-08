//
//  GifViewController.m
//  99reddits
//
//  Created by Frank Jacob on 11/3/11.
//  Copyright (c) 2011 99 reddits. All rights reserved.
//

#import "GifViewController.h"

@interface GifViewController ()
- (void)resizeWebview:(BOOL)portrait;
@end

@implementation GifViewController

@synthesize gifData = _gifData;
@synthesize width;
@synthesize height;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[_gifData release];
	[_tapGesture release];
	
	[webView release];
	[overlayView release];
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
	
	_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
	_tapGesture.cancelsTouchesInView = NO;
	_tapGesture.enabled = YES;
	[overlayView addGestureRecognizer:_tapGesture];
}	

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
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
	[_gifData release];
	_gifData = [gifData retain];
}

- (void)didTap {
	[self dismissModalViewControllerAnimated:NO];
}

@end
