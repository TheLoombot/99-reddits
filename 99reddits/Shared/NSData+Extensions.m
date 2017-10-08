//
//  NSData+Extensions.m
//  99reddits
//
//  Created by Pietro Rea on 10/6/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import "NSData+Extensions.h"
#import <ImageIO/CGImageSource.h>

@implementation NSData (Extensions)

- (BOOL)isGif {
    size_t imageCount = 1;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    if (imageSource) {
        imageCount = CGImageSourceGetCount(imageSource);
        CFRelease(imageSource);
        if (imageCount > 1) {
            uint8_t c;
            [self getBytes:&c length:1];
            if (c == 0x47) {
                return YES;
            }
        }
    }
    return NO;
}

@end
