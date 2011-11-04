//
//  MainViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell {
	UIActivityIndicatorView *activityIndicator;
	UILabel *braketLabel;
	UILabel *unshowedLabel;
	UILabel *countLabel;
	
	int unshowedCount;
	int totalCount;
	BOOL loading;
	
	BOOL first;
}

- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading;

@end
