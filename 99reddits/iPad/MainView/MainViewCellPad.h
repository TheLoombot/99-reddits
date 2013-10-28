//
//  MainViewCellPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedditsAppDelegate;
@class MainViewControllerPad;
@class SubRedditItem;

@interface MainViewCellPad : UICollectionViewCell {
	RedditsAppDelegate *appDelegate;
	MainViewControllerPad *__weak mainViewController;
	SubRedditItem *__weak subReddit;

	UIView *imageOutlineView;
	UIImageView *imageView;
	UIButton *tapButton;
	UIActivityIndicatorView *activityIndicator;
	UIButton *deleteButton;
	UIImageView *unshowedBackImageView;
	UILabel *unshowedLabel;
	UILabel *nameLabel;
	UIImageView *animateImageView;

	int unshowedCount;
	int totalCount;
	BOOL loading;
	
	BOOL bFavorites;
	BOOL editing;

	BOOL imageEmpty;
}

@property (nonatomic, weak) MainViewControllerPad *mainViewController;
@property (nonatomic, weak) SubRedditItem *subReddit;
@property (nonatomic, readonly) UILabel *nameLabel;

- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading;
- (void)setTotalCount:(int)_totalCount;
- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
