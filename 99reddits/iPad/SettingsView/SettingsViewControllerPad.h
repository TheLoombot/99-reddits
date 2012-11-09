//
//  SettingsViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PurchaseManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@class RedditsAppDelegate;

@interface SettingsViewControllerPad : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UIScrollView *contentScrollView;
	IBOutlet UIView *buttonsView;
	IBOutlet UIButton *upgradeForMOARButton;
	IBOutlet UIButton *restoreUpdateButton;
	IBOutlet UIView *aboutView;
	IBOutlet UIButton *clearButton;
	IBOutlet UITableView *contentTableView;
	IBOutlet UIButton *aboutOutlineButton;
	IBOutlet UIWebView *aboutWebView;
	
	IBOutlet UIButton *emailButton;
	IBOutlet UIButton *tweetButton;
	
	NSString *imagesSeenString;
	NSString *titleString;
	NSString *imagesToNextTitleString;
	
	MBProgressHUD *hud;
}

@property (retain) MBProgressHUD *hud;

@end
