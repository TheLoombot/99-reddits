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
	MainViewControllerPad *mainViewController;
	SubRedditItem *subReddit;

	UIView *imageOutlineView;
	UIImageView *imageView;
	UIButton *tapButton;
	UIActivityIndicatorView *activityIndicator;
	UIButton *deleteButton;
	UIImageView *unshowedBackImageView;
	UILabel *unshowedLabel;
	UILabel *nameLabel;
	
	int unshowedCount;
	int totalCount;
	BOOL loading;
	
	BOOL bFavorites;
	BOOL editing;
}

@property (nonatomic, assign) MainViewControllerPad *mainViewController;
@property (nonatomic, assign) SubRedditItem *subReddit;
@property (nonatomic, readonly) UILabel *nameLabel;

- (void)setImage:(UIImage *)image;
- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading;
- (void)setTotalCount:(int)_totalCount;

@end
