//
//  SettingsViewController.h
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PurchaseManager.h"


@class RedditsAppDelegate;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UIScrollView *contentScrollView;
	IBOutlet UIView *buttonsView;
	IBOutlet UIButton *upgradeForMOARButton;
	IBOutlet UIButton *restoreUpdateButton;
	IBOutlet UIView *aboutView;
	IBOutlet UITableView *contentTableView;
	IBOutlet UIButton *aboutOutlineButton;
	IBOutlet UIWebView *aboutWebView;
	
	NSString *imagesSeenString;
	NSString *titleString;
	NSString *imagesToNextTitleString;

	MBProgressHUD *hud;
}

@property (retain) MBProgressHUD *hud;

@end
