//
//  AlbumViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class AlbumViewController;

@interface AlbumViewCell : UICollectionViewCell

@property (nonatomic, strong) PhotoItem *photo;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign, getter=isInsideFavoriesAlbum) BOOL insideFavoritesAlbum;

@end
