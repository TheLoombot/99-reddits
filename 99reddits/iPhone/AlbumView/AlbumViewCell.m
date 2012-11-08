//
//  AlbumViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AlbumViewCell.h"
#import "AlbumViewCellItem.h"
#import "AlbumViewController.h"

@implementation AlbumViewCell

@synthesize albumViewController;
@synthesize photosArray;
@synthesize row;
@synthesize bFavorites;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		item1 = [[AlbumViewCellItem alloc] initWithFrame:CGRectMake(4, 4, 75, 75)];
		[item1 addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item1];
		
		item2 = [[AlbumViewCellItem alloc] initWithFrame:CGRectMake(83, 4, 75, 75)];
		[item2 addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item2];
		
		item3 = [[AlbumViewCellItem alloc] initWithFrame:CGRectMake(162, 4, 75, 75)];
		[item3 addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item3];
		
		item4 = [[AlbumViewCellItem alloc] initWithFrame:CGRectMake(241, 4, 75, 75)];
		[item4 addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item4];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)setRow:(int)_row {
	item1.bFavorites = bFavorites;
	item2.bFavorites = bFavorites;
	item3.bFavorites = bFavorites;
	item4.bFavorites = bFavorites;
	
	row = _row;
	
	int maxIndex = photosArray.count;
	
	int index = row * 4;
	if (index < maxIndex) {
		item1.photo = [photosArray objectAtIndex:index];
	}
	else {
		item1.photo = nil;
	}
	
	index ++;
	if (index < maxIndex) {
		item2.photo = [photosArray objectAtIndex:index];
	}
	else {
		item2.photo = nil;
	}
	
	index ++;
	if (index < maxIndex) {
		item3.photo = [photosArray objectAtIndex:index];
	}
	else {
		item3.photo = nil;
	}
	
	index ++;
	if (index < maxIndex) {
		item4.photo = [photosArray objectAtIndex:index];
	}
	else {
		item4.photo = nil;
	}
}

- (void)dealloc {
	[item1 release];
	[item2 release];
	[item3 release];
	[item4 release];
	[photosArray release];
	[albumViewController release];
	[super dealloc];
}

- (void)setImage:(UIImage *)image index:(int)index {
	switch (index) {
		case 0:
			[item1 setBackgroundImage:image forState:UIControlStateNormal];
			break;
		case 1:
			[item2 setBackgroundImage:image forState:UIControlStateNormal];
			break;
		case 2:
			[item3 setBackgroundImage:image forState:UIControlStateNormal];
			break;
		case 3:
			[item4 setBackgroundImage:image forState:UIControlStateNormal];
			break;
		default:
			break;
	}
}

- (void)onItemClick:(AlbumViewCellItem *)sender {
	[albumViewController onSelectPhoto:sender.photo];
}

@end
