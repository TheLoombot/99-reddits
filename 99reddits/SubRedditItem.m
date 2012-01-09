//
//  SubRedditItem.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubRedditItem.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "RedditsAppDelegate.h"


@implementation SubRedditItem

@synthesize nameString;
@synthesize urlString;
@synthesize photosArray;
@synthesize afterString;
@synthesize subscribe;
@synthesize loading;
@synthesize unshowedCount;

- (id)init {
	self = [super init];
	if (self) {
		photosArray = [[NSMutableArray alloc] init];
		loading = NO;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self) {
		self.nameString = [decoder decodeObjectForKey:@"name"];
		self.urlString = [decoder decodeObjectForKey:@"url"];
		
		if (!photosArray)
			photosArray = [[NSMutableArray alloc] init];
		NSData *data = [decoder decodeObjectForKey:@"photos"];
		if (data != nil) {
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			NSArray *array = [unarchiver decodeObjectForKey:@"data"];
			[unarchiver finishDecoding];
			[photosArray addObjectsFromArray:array];
			[unarchiver release];
		}
		
		self.afterString = [decoder decodeObjectForKey:@"after"];
		self.subscribe = [decoder decodeBoolForKey:@"subscribe"];
		
		loading = NO;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.nameString forKey:@"name"];
	[encoder encodeObject:self.urlString forKey:@"url"];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:photosArray forKey:@"data"];
	[archiver finishEncoding];
	[encoder encodeObject:data forKey:@"photos"];
	[archiver release];
	[data release];
	
	[encoder encodeObject:self.afterString forKey:@"after"];
	[encoder encodeBool:self.subscribe forKey:@"subscribe"];
}

- (void)dealloc {
	[nameString release];
	[urlString release];
	[photosArray release];
	[afterString release];
	[super dealloc];
}

- (void)removeAllCaches {
	for (PhotoItem *photo in photosArray) {
		if (photo.thumbnailString.length) {
			NSURL *thumbnailURL = [NSURL URLWithString:photo.thumbnailString];
			if (thumbnailURL)
				[[ASIDownloadCache sharedCache] removeCachedDataForURL:thumbnailURL];
		}

		if (photo.urlString.length) {
			NSURL *url = [NSURL URLWithString:photo.urlString];
			if (url)
				[[ASIDownloadCache sharedCache] removeCachedDataForURL:url];
		}
	}
}

- (void)calUnshowedCount {
	RedditsAppDelegate *appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	unshowedCount = 0;
	for (PhotoItem *item in photosArray) {
		if (![item isShowed])
			unshowedCount ++;
		else
			[appDelegate.showedSet addObject:item.idString];
	}
}

- (void)setNameString:(NSString *)_nameString {
	[nameString release];
	nameString = [_nameString retain];
}

- (void)setUrlString:(NSString *)_urlString {
	[urlString release];
	urlString = [_urlString retain];
}

- (void)setAfterString:(NSString *)_afterString {
	[afterString release];
	if (_afterString)
		afterString = [_afterString retain];
	else
		afterString = [[NSString alloc] initWithString:@""];
}

@end
