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
@class MainViewCellItemPad;

@interface MainViewCellPad : UITableViewCell {
	RedditsAppDelegate *appDelegate;
	MainViewControllerPad *mainViewController;
	NSMutableArray *subRedditsArray;
	int row;
	
	NSMutableArray *itemViewsArray;
}

@property (nonatomic, assign) MainViewControllerPad *mainViewController;
@property (nonatomic, assign) NSMutableArray *subRedditsArray;
@property (nonatomic, assign) int row;

- (void)setImage:(UIImage *)image index:(int)index;
- (void)onClick:(int)index;
- (void)onDeleteButton:(int)index;

@end
