//
//  URLProvider.m
//  99reddits
//
//  Created by aloomba on 10/24/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import "URLProvider.h"

@implementation URLProvider

- (id)initWithPlaceholderItem:(id)placeholderItem {
    self = [super initWithPlaceholderItem:placeholderItem];
    if (self) {
        url = placeholderItem;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard] || [activityType isEqualToString:UIActivityTypeMessage])
        return nil;
    
    return url;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.placeholderItem;
}

@end

