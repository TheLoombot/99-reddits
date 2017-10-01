//
//  NNImageLoader.h
//  99reddits
//
//  Created by Pietro Rea on 9/30/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

//Objective-C interface to Nuke
@interface NNImageLoader : NSObject

+ (void)loadImageWithUrlString:(NSString *)urlString intoImageView:(UIImageView *)imageview;

@end
