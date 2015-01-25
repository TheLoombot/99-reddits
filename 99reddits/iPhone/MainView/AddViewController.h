//
//  AddViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedditsAppDelegate;
@class RedditsViewController;

@interface AddViewController : UIViewController <UITextFieldDelegate> {
	RedditsAppDelegate *appDelegate;
	RedditsViewController __weak *redditsViewController;

	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UITextField *urlTextField;
	IBOutlet UIButton *tipButton;
}

@property (nonatomic, weak) RedditsViewController *redditsViewController;

@end
