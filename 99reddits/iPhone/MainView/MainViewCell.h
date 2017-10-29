//
//  MainViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell {
	UIActivityIndicatorView *activityIndicator;
	UILabel *contentTextLabel;
	UIView *unshowedBackView;
	UILabel *unshowedLabel;

	NSInteger unshowedCount;
	BOOL loading;
	BOOL imageEmpty;
}

@property (nonatomic, readonly) UILabel *contentTextLabel;
@property (strong, nonatomic) UIImageView *contentImageView;

- (void)setUnseenCount:(NSInteger)unseenCount isLoading:(BOOL)loading;

@end
