//
//  CustomTableView.m
//  99reddits
//
//  Created by Frank Jacob on 12/16/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:[UIButton class]])
		return YES;
	
	return [super touchesShouldCancelInContentView:view];
}

@end
