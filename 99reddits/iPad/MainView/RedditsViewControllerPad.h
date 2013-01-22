//
//  RedditsViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedditsAppDelegate;
@class MainViewControllerPad;
@class SubRedditItem;

@interface RedditsViewControllerPad : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	RedditsAppDelegate *appDelegate;
	MainViewControllerPad *mainViewController;
	
	IBOutlet UITableView *contentTableView;
	
	NSMutableArray *categoryArray;
	NSMutableArray *sectionArray;
	NSMutableSet *nameStringsSet;
}

@property (nonatomic, assign) MainViewControllerPad *mainViewController;

- (void)onManualAdded:(SubRedditItem *)subReddit;

@end
