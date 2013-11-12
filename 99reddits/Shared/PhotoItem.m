//
//  PhotoItem.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
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
	if (_idString)
		idString = _idString;
	else
		idString = @"";
}

- (void)setNameString:(NSString *)_nameString {
	if (_nameString)
		nameString = _nameString;
	else
		nameString = @"";
}

- (void)setPermalinkString:(NSString *)_permalinkString {
	if (_permalinkString)
		permalinkString = _permalinkString;
	else
		permalinkString = @"";
}

- (void)setThumbnailString:(NSString *)_thumbnailString {
	if (_thumbnailString)
		thumbnailString = _thumbnailString;
	else
		thumbnailString = @"";
}

- (void)setTitleString:(NSString *)_titleString {
	if (_titleString)
		titleString = _titleString;
	else
		titleString = @"";
}

- (void)setUrlString:(NSString *)_urlString {
	if (_urlString)
		urlString = _urlString;
	else
		urlString = @"";
}

@end
