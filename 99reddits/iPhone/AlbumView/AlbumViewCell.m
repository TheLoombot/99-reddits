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
@property (strong, nonatomic) UIImageView *favoriteOverlayView;

@end

@implementation AlbumViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];

        self.favoriteOverlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.favoriteOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.favoriteOverlayView];

        self.tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tapButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tapButton setImage:[UIImage imageNamed:@"ButtonOverlay.png"] forState:UIControlStateHighlighted];
        [self.tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.tapButton];

        [self activateConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.imageView.image = [UIImage imageNamed:@"DefaultPhoto"];
}

- (void)onTap:(id)sender {
    [self.albumViewController onSelectPhoto:self.photo];
}

- (void)setPhoto:(PhotoItem *)aPhoto {
    _photo = nil;
    _photo = aPhoto;

    if (self.isInsideFavoriesAlbum) {
        self.favoriteOverlayView.hidden = YES;
        self.favoriteOverlayView.image = nil;
    }
    else {
        if ([appDelegate isFavorite:_photo]) {
            self.favoriteOverlayView.hidden = NO;
            self.favoriteOverlayView.image = [UIImage imageNamed:@"FavoritesRedIcon.png"];
        }
        else {
            self.favoriteOverlayView.hidden = YES;
            self.favoriteOverlayView.image = nil;
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

    NSArray *overlayConstraints = @[[self.favoriteOverlayView.heightAnchor constraintEqualToConstant:25],
                                  [self.favoriteOverlayView.widthAnchor constraintEqualToConstant:25],
                                  [self.favoriteOverlayView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
                                  [self.favoriteOverlayView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]];

    [NSLayoutConstraint activateConstraints:overlayConstraints];



    NSArray *buttonConstraints = @[[self.tapButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
                                  [self.tapButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
                                  [self.tapButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
                                  [self.tapButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]];

    [NSLayoutConstraint activateConstraints:buttonConstraints];
}

@end
