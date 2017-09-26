//
//  AddViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AddViewController.h"
#import "RedditsViewController.h"
#import "UserDef.h"

@interface AddViewController ()

- (IBAction)onCancelButton;

@end

@implementation AddViewController

@synthesize redditsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Type a Sub-reddit";
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	urlTextField.text = @"/r/";
	[urlTextField becomeFirstResponder];

	tipButton.titleLabel.numberOfLines = 0;
	tipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[tipButton setTitle:@"Tip: To delete a sub-reddit, swipe your\nfinger across it." forState:UIControlStateNormal];
	[tipButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)onCancelButton {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	BOOL correct = NO;
	
	NSString *nameString;
	
	NSString *urlString = textField.text;
	if (urlString.length != 0) {
		if ([urlString hasPrefix:@"/r/"]) {
			urlString = [urlString substringFromIndex:3];
		}
		
		if (urlString.length != 0) {
			NSArray *array = [urlString componentsSeparatedByString:@"/"];
			if (array.count == 2) {
				if ([[array objectAtIndex:0] length] != 0 && [[array lastObject] length] != 0) {
					if ([[array lastObject] hasPrefix:@".json"]) {
						correct = YES;
						
						nameString = [array objectAtIndex:0];
					}
				}
			}
			else if (array.count == 1) {
				if ([[array objectAtIndex:0] length] != 0) {
					correct = YES;
					
					nameString = [array objectAtIndex:0];
				}
			}
		}
	}
	
	if (correct) {
		[redditsViewController onManualAdded:nameString];
	}
	else {
		[redditsViewController onManualAdded:nil];
	}
	
	return YES;
}

@end
