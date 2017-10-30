//
//  AlbumViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AlbumViewCell.h"
#import "AlbumViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AlbumViewCell()

@property (strong, nonatomic) UIButton *tapButton;
@property (strong, nonatomic) UIImageView *favoriteOverlayImageView;

@end

@implementation AlbumViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;

        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
        selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.selectedBackgroundView = selectedBackgroundView;

        appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.backgroundView addSubview:self.imageView];

        self.favoriteOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.favoriteOverlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.favoriteOverlayImageView];
        
        [self activateConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.imageView.image = [UIImage imageNamed:@"DefaultPhoto"];
}

- (void)setPhoto:(PhotoItem *)aPhoto {
    _photo = nil;
    _photo = aPhoto;

    if (!self.isInsideFavoriesAlbum) {
        self.favoriteOverlayImageView.hidden = YES;
        self.favoriteOverlayImageView.image = nil;
    }
    else {
        if ([appDelegate isFavorite:_photo]) {
            self.favoriteOverlayImageView.hidden = NO;
            self.favoriteOverlayImageView.image = [UIImage imageNamed:@"FavoritesRedIcon.png"];
        }
        else {
            self.favoriteOverlayImageView.hidden = YES;
            self.favoriteOverlayImageView.image = nil;
        }
    }
}

#pragma mark - Helper methods

- (void)activateConstraints {

    NSArray *imageConstraints = @[[self.imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
                                  [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
                                  [self.imageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
                                  [self.imageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]];

    [NSLayoutConstraint activateConstraints:imageConstraints];

    NSArray *overlayConstraints = @[[self.favoriteOverlayImageView.heightAnchor constraintEqualToConstant:25],
                                  [self.favoriteOverlayImageView.widthAnchor constraintEqualToConstant:25],
                                  [self.favoriteOverlayImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
                                  [self.favoriteOverlayImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]];

    [NSLayoutConstraint activateConstraints:overlayConstraints];
}

@end
