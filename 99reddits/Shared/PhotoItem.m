//
//  PhotoItem.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoItem.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "RedditsAppDelegate.h"


@implementation PhotoItem

@synthesize idString;
@synthesize nameString;
@synthesize permalinkString;
@synthesize thumbnailString;
@synthesize titleString;
@synthesize urlString;
//@synthesize showed;

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self) {
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		self.idString = [decoder decodeObjectForKey:@"id"];
		self.nameString = [decoder decodeObjectForKey:@"name"];
		self.permalinkString = [decoder decodeObjectForKey:@"permalink"];
		self.thumbnailString = [decoder decodeObjectForKey:@"thumbnail"];
		self.titleString = [decoder decodeObjectForKey:@"title"];
		self.urlString = [decoder decodeObjectForKey:@"url"];
//		self.showed = [decoder decodeBoolForKey:@"showed"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.idString forKey:@"id"];
	[encoder encodeObject:self.nameString forKey:@"name"];
	[encoder encodeObject:self.permalinkString forKey:@"permalink"];
	[encoder encodeObject:self.thumbnailString forKey:@"thumbnail"];
	[encoder encodeObject:self.titleString forKey:@"title"];
	[encoder encodeObject:self.urlString forKey:@"url"];
//	[encoder encodeBool:self.showed forKey:@"showed"];
}

- (void)dealloc {
	[idString release];
	[nameString release];
	[permalinkString release];
	[thumbnailString release];
	[titleString release];
	[urlString release];
	[super dealloc];
}

- (void)removeCaches {
	if (self.thumbnailString.length) {
		NSURL *thumbnailURL = [NSURL URLWithString:self.thumbnailString];
		if (thumbnailURL)
			[[ASIDownloadCache sharedCache] removeCachedDataForURL:thumbnailURL];
	}

	if (self.urlString.length) {
		NSURL *url = [NSURL URLWithString:self.urlString];
		if (url)
			[[ASIDownloadCache sharedCache] removeCachedDataForURL:url];
	}
}

- (BOOL)isShowed {
	if (appDelegate == nil)
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

	return [appDelegate.showedSet containsObject:idString];
}

- (void)setIdString:(NSString *)_idString {
	[idString release];
	idString = [_idString retain];
}

- (void)setNameString:(NSString *)_nameString {
	[nameString release];
	nameString = [_nameString retain];
}

- (void)setPermalinkString:(NSString *)_permalinkString {
	[permalinkString release];
	permalinkString = [_permalinkString retain];
}

- (void)setThumbnailString:(NSString *)_thumbnailString {
	[thumbnailString release];
	thumbnailString = [_thumbnailString retain];
}

- (void)setTitleString:(NSString *)_titleString {
	[titleString release];
	titleString = [_titleString retain];
}

- (void)setUrlString:(NSString *)_urlString {
	[urlString release];
	urlString = [_urlString retain];
}

@end
