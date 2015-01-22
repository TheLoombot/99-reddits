//
//  SubRedditItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoItem.h"

@interface SubRedditItem : NSObject {
	NSString *nameString;
	NSString *urlString;
	NSMutableArray *photosArray;
	NSString *afterString;
	NSString *category;
	BOOL subscribe;
	
	BOOL loading;
	
	NSInteger unshowedCount;
}

@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic) NSMutableArray *photosArray;
@property (nonatomic, strong) NSString *afterString;
@property (nonatomic, strong) NSString *category;
@property (nonatomic) BOOL subscribe;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSInteger unshowedCount;

- (void)removeAllCaches;
- (void)calUnshowedCount;

@end
