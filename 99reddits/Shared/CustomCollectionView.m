//
//  CustomCollectionView.m
//  99reddits
//
//  Created by Frank Jacob on 1/21/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CustomCollectionView.h"

@implementation CustomCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:[UIButton class]])
		return YES;
	
	return [super touchesShouldCancelInContentView:view];
}

@end
