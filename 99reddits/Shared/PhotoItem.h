//
//  PhotoItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RedditsAppDelegate;

@interface PhotoItem : NSObject {
	RedditsAppDelegate *appDelegate;
	
	NSString *idString;
	NSString *nameString;
	NSString *permalinkString;
	NSString *thumbnailString;
	NSString *titleString;
	NSString *urlString;
//	BOOL showed;
}

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *permalinkString;
@property (nonatomic, strong) NSString *thumbnailString;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *urlString;
//@property (nonatomic) BOOL showed;

- (BOOL)isShowed;
- (void)removeCaches;

@end
