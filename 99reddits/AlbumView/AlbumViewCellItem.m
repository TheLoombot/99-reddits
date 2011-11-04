//
//  AlbumViewCellItem.m
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewCellItem.h"
#import "AlbumViewCell.h"
#import "AlbumViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation AlbumViewCellItem

@synthesize photo;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
		[self addSubview:overlayView];
		
		self.photo = nil;
    }
    return self;
}

- (void)dealloc {
	[photo release];
	[overlayView release];
	[super dealloc];
}

- (void)setPhoto:(PhotoItem *)_photo {
	[photo release];
	photo = nil;
	
	if (_photo) {
		self.hidden = NO;
		
		photo = [_photo retain];
		
		if (photo.showed) {
			overlayView.hidden = NO;
			overlayView.image = [UIImage imageNamed:@"Overlay.png"];
		}
		else {
			overlayView.hidden = YES;
			overlayView.image = nil;
		}
	}
	else {
		self.hidden = YES;
		overlayView.image = nil;
	}
}

@end
