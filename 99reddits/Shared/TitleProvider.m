//
//  TitleProvider.m
//  99reddits
//
//  Created by Frank J. on 1/29/15.
//  Copyright (c) 2015 99 reddits. All rights reserved.
//

#import "TitleProvider.h"

@implementation TitleProvider

- (id)initWithPlaceholderItem:(id)placeholderItem {
	self = [super initWithPlaceholderItem:placeholderItem];
	if (self) {
		title = placeholderItem;
	}
	
	return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
	if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard])
		return nil;
	
	return title;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return self.placeholderItem;
}

@end
