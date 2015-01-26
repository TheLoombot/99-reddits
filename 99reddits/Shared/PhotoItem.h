//
//  PhotoItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoItem : NSObject {
	NSString *idString;
	NSString *nameString;
	NSString *permalinkString;
	NSString *thumbnailString;
	NSString *titleString;
	NSString *urlString;
}

@property (nonatomic, copy) NSString *idString;
@property (nonatomic, copy) NSString *nameString;
@property (nonatomic, copy) NSString *permalinkString;
@property (nonatomic, copy) NSString *thumbnailString;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *urlString;

- (BOOL)isShowed;
- (void)removeCaches;
- (BOOL)isGif;

@end
