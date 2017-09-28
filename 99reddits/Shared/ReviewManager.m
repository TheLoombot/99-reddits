//
//  ReviewManager.m
//  99reddits
//
//  Created by Pietro Rea on 9/27/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import "ReviewManager.h"

NSString *const SettingsAppStoreURLString = @"itms-apps://itunes.com/apps/lensie/99reddits";
NSString *const AppStoreReviewURLString = @"itms-apps://itunes.apple.com/app/id474846610?action=write-review";

@implementation ReviewManager

+ (void)linkToAppStoreReviewPage {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreReviewURLString]];
}

@end
