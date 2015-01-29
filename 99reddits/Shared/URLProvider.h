//
//  URLProvider.h
//  99reddits
//
//  Created by Frank J. on 1/29/15.
//  Copyright (c) 2015 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLProvider : UIActivityItemProvider <UIActivityItemSource> {
	NSURL *url;
}

@end
