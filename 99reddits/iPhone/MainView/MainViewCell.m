//
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
@property (strong, nonatomic) UIView *unshowedBackView;
@property (strong, nonatomic) UILabel *unshowedLabel;
@property (assign, nonatomic) NSInteger unshowedCount;
@property (assign, nonatomic, getter=isLoading) BOOL loading;

@end

@implementation MainViewCell

@synthesize contentTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.contentImageView];

        self.contentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.contentView.frame.size.width - 140, 55)];
        self.contentTextLabel.font = [UIFont boldSystemFontOfSize:16];
        self.contentTextLabel.textColor = [UIColor blackColor];
        self.contentTextLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.contentTextLabel];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;

        self.unshowedBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.unshowedBackView.userInteractionEnabled = NO;
        self.unshowedBackView.backgroundColor = [UIColor redColor];
        self.unshowedBackView.clipsToBounds = YES;
        self.unshowedBackView.layer.cornerRadius = 12;
        [self addSubview:self.unshowedBackView];

        self.unshowedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.unshowedLabel.font = [UIFont boldSystemFontOfSize:17];
        self.unshowedLabel.backgroundColor = [UIColor clearColor];
        self.unshowedLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.unshowedLabel];

        self.unshowedBackView.hidden = YES;
        self.unshowedLabel.hidden = YES;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentImageView.image = [UIImage imageNamed:@"DefaultAlbumIcon"];
    self.unshowedBackView.hidden = YES;
    self.unshowedLabel.hidden = YES;
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
        self.unshowedBackView.hidden = NO;
        self.unshowedLabel.hidden = NO;

        CGRect frame = self.textLabel.frame;
        frame.size.width = 180;
        self.textLabel.frame = frame;

        self.unshowedLabel.frame = CGRectMake(0, 0, 200, 20);
        self.unshowedLabel.text = [NSString stringWithFormat:@"%ld", (long)self.unshowedCount];
        [self.unshowedLabel sizeToFit];

        CGRect rect = self.unshowedLabel.frame;
        rect.size.width = ceil(rect.size.width);
        if (rect.size.width < 10) {
            rect.size.width = 10;
        }

        rect.size.height = 20;
        rect.origin.x = self.contentView.frame.size.width - 45 - rect.size.width;
        rect.origin.y = 17;
        self.unshowedLabel.frame = rect;

        rect.origin.x -= 7;
        rect.origin.y -= 2;
        rect.size.width += 14;
        rect.size.height += 4;
        self.unshowedBackView.frame = rect;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 if (editing) {
							 self.unshowedBackView.alpha = 0.0;
							 self.unshowedLabel.alpha = 0.0;
						 }
						 else {
							 self.unshowedBackView.alpha = 1.0;
							 self.unshowedLabel.alpha = 1.0;
						 }
					 }];
}

@end
