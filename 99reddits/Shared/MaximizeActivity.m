//
//  MaximizeActivity.m
//  99reddits
//
//  Created by Frank J. on 1/28/15.
//  Copyright (c) 2015 99 reddits. All rights reserved.
//

#import "MaximizeActivity.h"

@implementation MaximizeActivity

@synthesize delegate;
@synthesize canPerformActivity;

+ (UIActivityCategory)activityCategory {
	return UIActivityCategoryAction;
}

- (NSString *)activityType {
	return @"99reddits.maximize";
}

- (NSString *)activityTitle {
	return @"Full Size";
}

- (UIImage *)activityImage {
	if (isPad)
		return [UIImage imageNamed:@"MaximizePad.png"];
	
	return [UIImage imageNamed:@"Maximize.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	return canPerformActivity;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
}

- (UIViewController *)activityViewController {
	return nil;
}

- (void)performActivity {
	[delegate performMaximize];
}

@end
