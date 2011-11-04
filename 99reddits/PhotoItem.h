//
//  PhotoItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoItem : NSObject {
	NSString *idString;
	NSString *nameString;
	NSString *permalinkString;
	NSString *thumbnailString;
	NSString *titleString;
	NSString *urlString;
	BOOL showed;
}

@property (nonatomic, retain) NSString *idString;
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *permalinkString;
@property (nonatomic, retain) NSString *thumbnailString;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic) BOOL showed;

- (void)removeCaches;

@end
