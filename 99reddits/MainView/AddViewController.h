//
//  AddViewController.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RedditsAppDelegate;

@interface AddViewController : UIViewController <UITextFieldDelegate> {
	RedditsAppDelegate *appDelegate;
	
	IBOutlet UITextField *urlTextField;
	IBOutlet UIButton *tipButton;
}

@end
