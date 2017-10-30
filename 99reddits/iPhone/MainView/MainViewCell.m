
//  MainViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "MainViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewCell()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *unseenCountLabelBackground;
@property (strong, nonatomic) UILabel *unseenCountLabel;
@property (assign, nonatomic) NSInteger unshowedCount;
@property (assign, nonatomic, getter=isLoading) BOOL loading;

@end

@implementation MainViewCell

@synthesize contentTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.contentImageView];

        self.contentTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentTextLabel.font = [UIFont boldSystemFontOfSize:16];
        self.contentTextLabel.textColor = [UIColor blackColor];
        self.contentTextLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.contentTextLabel];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;

        self.unseenCountLabelBackground = [[UIView alloc] initWithFrame:CGRectZero];
        self.unseenCountLabelBackground.translatesAutoresizingMaskIntoConstraints = NO;
        self.unseenCountLabelBackground.userInteractionEnabled = NO;
        self.unseenCountLabelBackground.backgroundColor = [UIColor redColor];
        self.unseenCountLabelBackground.clipsToBounds = YES;
        self.unseenCountLabelBackground.layer.cornerRadius = 12;
        [self addSubview:self.unseenCountLabelBackground];

        self.unseenCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.unseenCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.unseenCountLabel.font = [UIFont boldSystemFontOfSize:17];
        self.unseenCountLabel.backgroundColor = [UIColor clearColor];
        self.unseenCountLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.unseenCountLabel];

        self.unseenCountLabelBackground.hidden = YES;
        self.unseenCountLabel.hidden = YES;

        [self activateConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    //So that the view remains red when the cell is highlighted
    self.unseenCountLabelBackground.backgroundColor = [UIColor redColor];
}


- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentImageView.image = [UIImage imageNamed:@"DefaultAlbumIcon"];
    self.unseenCountLabelBackground.hidden = YES;
    self.unseenCountLabel.hidden = YES;
}

- (void)setUnseenCount:(NSInteger)unseenCount isLoading:(BOOL)loading {
    
    self.unshowedCount = unseenCount;
    self.loading = loading;

    if (loading) {
        self.accessoryView = self.activityIndicator;
        [self.activityIndicator startAnimating];
    }
    else {
        self.accessoryView = nil;
    }

    if (self.unshowedCount > 0) {
        self.unseenCountLabelBackground.hidden = NO;
        self.unseenCountLabel.hidden = NO;

        self.unseenCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.unshowedCount];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 if (editing) {
							 self.unseenCountLabelBackground.alpha = 0.0;
							 self.unseenCountLabel.alpha = 0.0;
						 }
						 else {
							 self.unseenCountLabelBackground.alpha = 1.0;
							 self.unseenCountLabel.alpha = 1.0;
						 }
					 }];
}

//MARK: Helper methods

- (void)activateConstraints {

    NSArray *imageConstraints = @[[self.contentImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
                                  [self.contentImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
                                  [self.contentImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
                                  [self.contentImageView.widthAnchor constraintEqualToAnchor:self.contentView.heightAnchor]];

    [NSLayoutConstraint activateConstraints:imageConstraints];

    NSArray *textConstraints = @[[self.contentTextLabel.leadingAnchor constraintEqualToAnchor:self.contentImageView.trailingAnchor constant:5],
                                 [self.contentTextLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:10],
                                 [self.contentTextLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-10],
                                 [self.contentTextLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]];

    [NSLayoutConstraint activateConstraints:textConstraints];

    NSArray *unseenConstraints = @[[self.unseenCountLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-45],
                                   [self.unseenCountLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:10],
                                   [self.unseenCountLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-10],
                                   [self.unseenCountLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]];

    [NSLayoutConstraint activateConstraints:unseenConstraints];

    NSArray *unseenBackgroundConstraints = @[[self.unseenCountLabelBackground.widthAnchor constraintEqualToAnchor:self.unseenCountLabel.widthAnchor constant:14],
                                             [self.unseenCountLabelBackground.heightAnchor constraintEqualToAnchor:self.unseenCountLabel.heightAnchor constant:4],
                                             [self.unseenCountLabelBackground.centerXAnchor constraintEqualToAnchor:self.unseenCountLabel.centerXAnchor],
                                             [self.unseenCountLabelBackground.centerYAnchor constraintEqualToAnchor:self.unseenCountLabel.centerYAnchor]];

    [NSLayoutConstraint activateConstraints:unseenBackgroundConstraints];
}

@end
