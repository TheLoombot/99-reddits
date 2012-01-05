//
//  RedditsViewController.m
//  99reddits
//
//  Created by Frank Jacob on 1/4/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import "RedditsViewController.h"
#import "RedditsAppDelegate.h"
#import "MainViewController.h"
#import "AddViewController.h"


@interface RedditsViewController ()

- (IBAction)onDoneButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

@end

@implementation RedditsViewController

@synthesize mainViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	[originalSubRedditsArray release];
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
	originalSubRedditsArray = [[NSMutableArray alloc] initWithArray:appDelegate.subRedditsArray];
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

- (void)viewWillAppear:(BOOL)animated {
	[contentTableView reloadData];
}

- (IBAction)onDoneButton:(id)sender {
	[appDelegate refreshSubscribe];
	
	for (SubRedditItem *subReddit in originalSubRedditsArray) {
		BOOL bExist = NO;
		for (SubRedditItem *tempSubReddit in appDelegate.subRedditsArray) {
			if (subReddit == tempSubReddit) {
				bExist = YES;
				break;
			}
		}
		
		if (!bExist) {
			[mainViewController removeSubRedditOperations:subReddit];
		}
	}
	
	for (SubRedditItem *subReddit in appDelegate.subRedditsArray) {
		BOOL bExist = NO;
		for (SubRedditItem *tempSubReddit in originalSubRedditsArray) {
			if (subReddit == tempSubReddit) {
				bExist = YES;
				break;
			}
		}
		
		if (!bExist) {
			[mainViewController addSubReddit:subReddit];
		}
	}
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)onAddButton:(id)sender {
	AddViewController *addViewController = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
	[self presentModalViewController:addViewController animated:YES];
	[addViewController release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return appDelegate.allSubRedditsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"REDDITS_VIEW_CELL";
	
	UITableViewCell *cell = [contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
	}
	
	SubRedditItem *subReddit = [appDelegate.allSubRedditsArray objectAtIndex:indexPath.row];
	cell.textLabel.text = subReddit.nameString;
	if (subReddit.subscribe) {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"CheckIcon.png"];
	}
	else {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UncheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"UncheckIcon.png"];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[contentTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	SubRedditItem *subReddit = [appDelegate.allSubRedditsArray objectAtIndex:indexPath.row];
	UITableViewCell *cell = [contentTableView cellForRowAtIndexPath:indexPath];
	subReddit.subscribe = !subReddit.subscribe;
	if (subReddit.subscribe) {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"CheckIcon.png"];
	}
	else {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UncheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"UncheckIcon.png"];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		SubRedditItem *subReddit = [appDelegate.allSubRedditsArray objectAtIndex:indexPath.row];
		[mainViewController removeSubRedditOperations:subReddit];
		[subReddit removeAllCaches];
		[appDelegate.subRedditsArray removeObject:subReddit];
		[appDelegate.allSubRedditsArray removeObject:subReddit];
		[contentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
}

@end
