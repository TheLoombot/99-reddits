//
//  MainViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell 

@property (nonatomic, strong) UILabel *contentTextLabel;
@property (nonatomic, strong) UIImageView *contentImageView;

- (void)setUnseenCount:(NSInteger)unseenCount isLoading:(BOOL)loading;

@end
