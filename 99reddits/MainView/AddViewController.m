//
//  AddViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"
#import "RedditsAppDelegate.h"
#import "MainViewController.h"
#import "UserDef.h"


@interface AddViewController ()

- (IBAction)onCancelButton;

@end

@implementation AddViewController

@synthesize mainViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	urlTextField.text = @"/r/";
	[urlTextField becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onCancelButton {
	[self dismissModalViewControllerAnimated:YES];
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
						urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT2, urlString];
					}
				}
			}
			else if (array.count == 1) {
				if ([[array objectAtIndex:0] length] != 0) {
					correct = YES;
					
					nameString = [array objectAtIndex:0];
					urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, nameString];
				}
			}
		}
	}
	
	if (correct) {
		BOOL bExist = NO;
		for (SubRedditItem *subReddit in appDelegate.subRedditsArray) {
			if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
				bExist = YES;
				break;
			}
		}
		
		if (!bExist) {
			SubRedditItem *subReddit = [[SubRedditItem alloc] init];
			subReddit.nameString = nameString;
			subReddit.urlString = urlString;
			[appDelegate.subRedditsArray addObject:subReddit];
			[subReddit release];
			
			[mainViewController onAddedItem:appDelegate.subRedditsArray.count - 1];
		}
		
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		[self dismissModalViewControllerAnimated:YES];
	}
	
	return YES;
}

@end
