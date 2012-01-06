//
//  AddViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RedditsAppDelegate;
@class RedditsViewController;

@interface AddViewController : UIViewController <UITextFieldDelegate> {
	RedditsAppDelegate *appDelegate;
	RedditsViewController *redditsViewController;
	
	IBOutlet UITextField *urlTextField;
	IBOutlet UIButton *tipButton;
}

@property (nonatomic, assign) RedditsViewController *redditsViewController;

@end
