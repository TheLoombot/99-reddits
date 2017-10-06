//
//  NSData+Extensions.h
//  99reddits
//
//  Created by Pietro Rea on 10/6/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSData (Extensions)

//Determins if a binary is a gif based on the number of images in the image blob and the file extension (via first byte).
- (BOOL)isGif;

@end
