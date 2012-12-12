//
//  PopoverController.m
//  99reddits
//
//  Created by Frank Jacob on 12/10/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PopoverController.h"
#import <QuartzCore/QuartzCore.h>

@interface PopoverWindow : UIWindow

@property (nonatomic, retain) UIWindow *oldKeyWindow;

@end

@implementation PopoverWindow

@synthesize oldKeyWindow;

- (void)makeKeyAndVisible {
	self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
	self.windowLevel = UIWindowLevelAlert;
	[super makeKeyAndVisible];
}

- (void)resignKeyWindow {
	[super resignKeyWindow];
	[self.oldKeyWindow makeKeyWindow];
}

- (void)dealloc {
	self.oldKeyWindow = nil;
	[super dealloc];
}

@end

@interface PopoverViewController : UIViewController

@property (nonatomic, assign) UIViewController *contentViewController;
@property (nonatomic, assign) BOOL fullscreen;

@end

@implementation PopoverViewController

@synthesize contentViewController;
@synthesize fullscreen;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	UIViewController *viewController = self.contentViewController;
	if ([viewController isKindOfClass:[UINavigationController class]])
		viewController = [(UINavigationController *)viewController topViewController];
	if ([viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
		return [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
	return YES;
}

- (BOOL)shouldAutorotate {
	UIViewController *viewController = self.contentViewController;
	if ([viewController isKindOfClass:[UINavigationController class]])
		viewController = [(UINavigationController *)viewController topViewController];
	if ([viewController respondsToSelector:@selector(shouldAutorotate)])
		return [viewController shouldAutorotate];
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	if (self.fullscreen) {
		UIViewController *viewController = self.contentViewController;
		if ([viewController isKindOfClass:[UINavigationController class]])
			viewController = [(UINavigationController *)viewController topViewController];
		[viewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
		return;
	}

	UIView *subview = [self.view.subviews lastObject];
	if (!subview)
		return;

	[UIView animateWithDuration:duration
					 animations:^{
						 subview.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
					 }];
}

@end

@implementation PopoverController

@synthesize delegate;
@synthesize popoverContentSize;
@synthesize fullscreen;

- (id)initWithContentViewController:(UIViewController *)viewController {
	self = [super init];
	if (self) {
		contentViewController = [viewController retain];
	}
	
	return self;
}

- (void)dealloc {
	[contentViewController release];
	[window release];
	[super dealloc];
}

- (void)showPopover:(BOOL)animated {
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];

	contentViewController.view.frame = CGRectMake(0, 0, popoverContentSize.width, popoverContentSize.height);
	contentViewController.view.autoresizingMask = UIViewAutoresizingNone;
	contentViewController.view.clipsToBounds = YES;
	contentViewController.view.layer.cornerRadius = 5;

	PopoverViewController *popoverViewController = [[[PopoverViewController alloc] init] autorelease];
	popoverViewController.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	popoverViewController.contentViewController = contentViewController;
	popoverViewController.fullscreen = fullscreen;
	[popoverViewController.view addSubview:contentViewController.view];

	window = [[PopoverWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	window.alpha = 0.0;
	window.backgroundColor = [UIColor clearColor];
	window.rootViewController = popoverViewController;
	[window makeKeyAndVisible];

	contentViewController.view.center = CGPointMake(CGRectGetMidX(popoverViewController.view.bounds), CGRectGetMidY(popoverViewController.view.bounds));
	
	if (fullscreen) {
		contentViewController.view.frame = popoverViewController.view.bounds;
		contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	
	if (animated) {
		[UIView animateWithDuration:0.2
						 animations:^{
							 window.alpha = 1.0;
						 }];
	}
	else {
		window.alpha = 1.0;
	}
}

- (void)dismissPopover:(BOOL)animated {
	if (animated) {
		[UIView animateWithDuration:0.2
						 animations:^{
							 [window resignKeyWindow];
							 window.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 [contentViewController.view removeFromSuperview];
							 contentViewController.view.alpha = 1.0;
							 
							 if ([delegate respondsToSelector:@selector(popoverControllerDidDismissed:)]) {
								 [delegate popoverControllerDidDismissed:self];
							 }
						 }];
	}
	else {
		[window resignKeyWindow];
		window.alpha = 0.0;
		
		[contentViewController.view removeFromSuperview];
		contentViewController.view.alpha = 1.0;
		
		if ([delegate respondsToSelector:@selector(popoverControllerDidDismissed:)]) {
			[delegate popoverControllerDidDismissed:self];
		}
	}
}

@end
