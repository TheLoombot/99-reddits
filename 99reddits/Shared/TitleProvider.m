//
//  TitleProvider.m
//  99reddits
//
//  Created by aloomba on 10/24/17.
//  Copyright © 2017 99 reddits. All rights reserved.
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
    if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard] || [activityType isEqualToString:UIActivityTypeMessage])
        return nil;
    
    return title;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.placeholderItem;
}

@end

