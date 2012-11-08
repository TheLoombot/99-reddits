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
	
	int unshowedCount;
}

@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) NSMutableArray *photosArray;
@property (nonatomic, retain) NSString *afterString;
@property (nonatomic, retain) NSString *category;
@property (nonatomic) BOOL subscribe;
@property (nonatomic) BOOL loading;
@property (nonatomic) int unshowedCount;

- (void)removeAllCaches;
- (void)calUnshowedCount;

@end
