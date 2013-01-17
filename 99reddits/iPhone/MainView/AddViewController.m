//
//  AddViewController.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AddViewController.h"
#import "RedditsAppDelegate.h"
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

- (void)dealloc {
	[urlTextField release];
	[tipButton release];
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

	tipButton.titleLabel.numberOfLines = 0;
	tipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[tipButton setTitle:@"Tip: To delete a sub-reddit, swipe your\nfinger across it." forState:UIControlStateNormal];
	[tipButton setBackgroundImage:[[UIImage imageNamed:@"ButtonNormal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
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

- (BOOL)shouldAutorotate {
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)onCancelButton {
	[self dismissViewControllerAnimated:YES completion:nil];
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
		SubRedditItem *tempSubReddit;
		for (SubRedditItem *subReddit in appDelegate.staticSubRedditsArray) {
			if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
				tempSubReddit = subReddit;
				bExist = YES;
				break;
			}
		}
		
		if (!bExist) {
			for (SubRedditItem *subReddit in appDelegate.manualSubRedditsArray) {
				if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
					bExist = YES;
					break;
				}
			}
			
			if (!bExist) {
				SubRedditItem *subReddit = [[SubRedditItem alloc] init];
				subReddit.nameString = nameString;
				subReddit.urlString = urlString;
				subReddit.subscribe = YES;
				[appDelegate.manualSubRedditsArray addObject:subReddit];
				[subReddit release];
			}
		}
		else {
			tempSubReddit.subscribe = YES;
		}
	}

	[redditsViewController onManualAdded];
	
	return YES;
}

@end
