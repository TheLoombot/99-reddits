//
//  CacheCleaner.h
//  99reddits
//
//  Created by Pietro Rea on 11/13/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheCleaner : NSObject

//Removes `ASIDownloadCache` on a background thread. `ASIDownloadCache` was used up until v2.8.2 of the app
+ (void)cleanCache;

@end
