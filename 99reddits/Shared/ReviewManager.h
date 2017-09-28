//
//  ReviewManager.h
//  99reddits
//
//  Created by Pietro Rea on 9/27/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SettingsAppStoreURLString;
extern NSString *const AppStoreReviewURLString;

@interface ReviewManager : NSObject

+ (void)linkToAppStoreReviewPage;

@end
