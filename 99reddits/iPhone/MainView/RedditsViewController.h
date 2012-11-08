//
//  RedditsViewController.h
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedditsAppDelegate;
@class MainViewController;

@interface RedditsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	RedditsAppDelegate *appDelegate;
	MainViewController *mainViewController;
	
	IBOutlet UITableView *contentTableView;
	
	NSMutableArray *originalSubRedditsArray;
	
	NSMutableArray *categoryArray;
	NSMutableArray *sectionArray;
}

@property (nonatomic, assign) MainViewController *mainViewController;

- (void)onManualAdded;

@end
