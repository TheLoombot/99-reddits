//
//  URLProvider.h
//  99reddits
//
//  Created by aloomba on 10/24/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLProvider : UIActivityItemProvider <UIActivityItemSource> {
    NSURL *url;
}

@end

