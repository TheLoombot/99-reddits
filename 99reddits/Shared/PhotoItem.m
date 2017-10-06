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

@implementation PhotoItem

@synthesize idString;
@synthesize nameString;
@synthesize permalinkString;
@synthesize thumbnailString;
@synthesize titleString;
@synthesize urlString;

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

- (NSString *)photoViewControllerURLString {

    if (appDelegate == nil) {
        appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
    }

    NSString *source = self.urlString;

    if (![appDelegate isFullImage:source] && ![self isGif]) {
        NSString *hugeSource = [appDelegate getHugeImage:source];
        if (![hugeSource isEqualToString:source]) {
            source = hugeSource;
        }
    }

    return source;
}

- (BOOL)isGif {
	if ([self.nameString rangeOfString:@"gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
		return YES;

	if ([self.titleString rangeOfString:@"gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
		return YES;

	if ([self.permalinkString rangeOfString:@"gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
		return YES;

	if ([[[self.urlString pathExtension] lowercaseString] isEqualToString:@"gif"])
		return YES;
	
	return NO;
}

@end
