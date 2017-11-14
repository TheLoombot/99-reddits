//
//  CacheCleaner.m
//  99reddits
//
//  Created by Pietro Rea on 11/13/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import "CacheCleaner.h"

@implementation CacheCleaner

+ (void)cleanCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ASIHTTPRequestCache"];
        NSString *cachePath = [path stringByAppendingPathComponent:@"PermanentStore"];

        NSError *fileManagerError;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:cachePath error:&fileManagerError];

        if (!success) {
            NSLog(@"%@: Could not remove cache. %@", NSStringFromClass(self), fileManagerError);
        } else {
            NSLog(@"%@: Removed cache successfully", NSStringFromClass(self));
        }
    });
}

@end
