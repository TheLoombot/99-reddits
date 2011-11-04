//
//  AddViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RedditsAppDelegate;
@class MainViewController;

@interface AddViewController : UIViewController <UITextFieldDelegate> {
	RedditsAppDelegate *appDelegate;
	MainViewController *mainViewController;
	
	IBOutlet UITextField *urlTextField;
}

@property (nonatomic, assign) MainViewController *mainViewController;

@end
