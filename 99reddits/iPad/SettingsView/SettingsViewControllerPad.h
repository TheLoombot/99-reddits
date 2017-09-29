//
//  SettingsViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "PopoverController.h"

@class RedditsAppDelegate;
@class MainViewControllerPad;

@interface SettingsViewControllerPad : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
	MainViewControllerPad __weak *mainViewController;
	PopoverController __weak *popoverController;

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
	IBOutlet UIButton *rateAppButton;
	
	NSString *imagesSeenString;
	NSString *titleString;
	NSString *imagesToNextTitleString;
	
	MBProgressHUD *hud;
}

@property (nonatomic, weak) MainViewControllerPad *mainViewController;
@property (nonatomic, weak) PopoverController *popoverController;

@end
