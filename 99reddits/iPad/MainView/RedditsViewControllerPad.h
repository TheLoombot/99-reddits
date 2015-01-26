//
//  RedditsViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewControllerPad;
@class SubRedditItem;

@interface RedditsViewControllerPad : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	MainViewControllerPad __weak *mainViewController;
	
	IBOutlet UITableView *contentTableView;
	
	NSMutableArray *categoryArray;
	NSMutableArray *sectionArray;
	NSMutableSet *nameStringsSet;
	
	NSString *manualAddedNameString;
}

@property (nonatomic, weak) MainViewControllerPad *mainViewController;

- (void)onManualAdded:(NSString *)nameString;

@end
