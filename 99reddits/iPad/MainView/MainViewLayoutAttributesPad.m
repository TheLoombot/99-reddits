//
//  MainViewLayoutAttributesPad.m
//  99reddits
//
//  Created by Frank Jacob on 1/21/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "MainViewLayoutAttributesPad.h"

@implementation MainViewLayoutAttributesPad

- (id)copyWithZone:(NSZone *)zone {
	MainViewLayoutAttributesPad *attributes = [super copyWithZone:zone];
	attributes.editing = _editing;
    return attributes;
}

@end
