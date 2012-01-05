//
//  SettingsViewController.h
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate> {
	IBOutlet UIScrollView *contentScrollView;
	IBOutlet UIButton *upgradeForMOARButton;
	IBOutlet UIButton *restoreUpdateButton;
	IBOutlet UITableView *contentTableView;
	IBOutlet UIButton *aboutOutlineButton;
	IBOutlet UIWebView *aboutWebView;
}

@end
