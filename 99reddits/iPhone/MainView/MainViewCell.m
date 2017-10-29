//
//  MainViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "MainViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewCell

@synthesize contentTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.contentImageView];

        contentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.contentView.frame.size.width - 140, 55)];
        contentTextLabel.font = [UIFont boldSystemFontOfSize:16];
        contentTextLabel.textColor = [UIColor blackColor];
        contentTextLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:contentTextLabel];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;

        unshowedBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        unshowedBackView.userInteractionEnabled = NO;
        unshowedBackView.backgroundColor = [UIColor redColor];
        unshowedBackView.clipsToBounds = YES;
        unshowedBackView.layer.cornerRadius = 12;
        [self addSubview:unshowedBackView];

        unshowedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        unshowedLabel.font = [UIFont boldSystemFontOfSize:17];
        unshowedLabel.backgroundColor = [UIColor clearColor];
        unshowedLabel.textColor = [UIColor whiteColor];
        [self addSubview:unshowedLabel];

        unshowedBackView.hidden = YES;
        unshowedLabel.hidden = YES;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentImageView.image = [UIImage imageNamed:@"DefaultAlbumIcon"];
    unshowedBackView.hidden = YES;
    unshowedLabel.hidden = YES;
}

- (void)setUnseenCount:(NSInteger)unseenCount isLoading:(BOOL)loading {
    
    unshowedCount = unseenCount;
    loading = loading;

    if (loading) {
        self.accessoryView = activityIndicator;
        [activityIndicator startAnimating];
    }
    else {
        self.accessoryView = nil;
    }

    if (unshowedCount > 0) {
        unshowedBackView.hidden = NO;
        unshowedLabel.hidden = NO;

        CGRect frame = self.textLabel.frame;
        frame.size.width = 180;
        self.textLabel.frame = frame;

        unshowedLabel.frame = CGRectMake(0, 0, 200, 20);
        unshowedLabel.text = [NSString stringWithFormat:@"%ld", (long)unshowedCount];
        [unshowedLabel sizeToFit];

        CGRect rect = unshowedLabel.frame;
        rect.size.width = ceil(rect.size.width);
        if (rect.size.width < 10) {
            rect.size.width = 10;
        }

        rect.size.height = 20;
        rect.origin.x = self.contentView.frame.size.width - 45 - rect.size.width;
        rect.origin.y = 17;
        unshowedLabel.frame = rect;

        rect.origin.x -= 7;
        rect.origin.y -= 2;
        rect.size.width += 14;
        rect.size.height += 4;
        unshowedBackView.frame = rect;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 if (editing) {
							 unshowedBackView.alpha = 0.0;
							 unshowedLabel.alpha = 0.0;
						 }
						 else {
							 unshowedBackView.alpha = 1.0;
							 unshowedLabel.alpha = 1.0;
						 }
					 }];
}

@end
