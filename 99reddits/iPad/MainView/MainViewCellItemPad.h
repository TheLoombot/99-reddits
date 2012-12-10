//
//  MainViewCellItemPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewCellPad;

@interface MainViewCellItemPad : UIView {
	MainViewCellPad *mainViewCell;
	
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

@property (nonatomic, assign) MainViewCellPad *mainViewCell;
@property (nonatomic, readonly) UILabel *nameLabel;

- (void)setImage:(UIImage *)image;
- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading;
- (void)setTotalCount:(int)_totalCount;
- (void)setEditing:(BOOL)_editing;

@end
