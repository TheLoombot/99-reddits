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
	UIImageView *contentImageView;
	UILabel *contentTextLabel;
	UIView *unshowedBackView;
	UILabel *unshowedLabel;
	UIImageView *animateImageView;

	NSInteger unshowedCount;
	NSInteger totalCount;
	BOOL loading;
	
	BOOL first;
	
	BOOL bFavorites;

	BOOL imageEmpty;
}

@property (nonatomic, readonly) UILabel *contentTextLabel;

- (void)setUnshowedCount:(NSInteger)_unshowedCount totalCount:(NSInteger)_totalCount loading:(BOOL)_loading;
- (void)setTotalCount:(NSInteger)_totalCount;
- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
