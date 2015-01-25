//
//  AddViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedditsAppDelegate;
@class RedditsViewControllerPad;

@interface AddViewControllerPad : UIViewController <UITextFieldDelegate> {
	RedditsAppDelegate *appDelegate;
	RedditsViewControllerPad __weak *redditsViewController;
	
	IBOutlet UITextField *urlTextField;
	IBOutlet UIButton *tipButton;
}

@property (nonatomic, weak) RedditsViewControllerPad *redditsViewController;

@end
