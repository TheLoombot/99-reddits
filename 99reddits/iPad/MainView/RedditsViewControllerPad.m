//
//  RedditsViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "RedditsViewControllerPad.h"
#import "RedditsAppDelegate.h"
#import "MainViewControllerPad.h"
#import "AddViewControllerPad.h"

@interface RedditsViewControllerPad ()

- (IBAction)onDoneButton:(id)sender;
- (IBAction)onAddButton:(id)sender;

@end

@implementation RedditsViewControllerPad

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
	[categoryArray release];
	[sectionArray release];
	
	[contentTableView release];
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
	
	categoryArray = [[NSMutableArray alloc] init];
	sectionArray = [[NSMutableArray alloc] init];
	
	for (SubRedditItem *subReddit in appDelegate.staticSubRedditsArray) {
		int index = -1;
		for (int i = 0; i < categoryArray.count; i ++) {
			if ([subReddit.category isEqualToString:[categoryArray objectAtIndex:i]]) {
				index = i;
				break;
			}
		}
		
		if (index == -1) {
			NSMutableArray *section = [[NSMutableArray alloc] init];
			[section addObject:subReddit];
			[sectionArray addObject:section];
			[categoryArray addObject:subReddit.category];
			[section release];
		}
		else {
			NSMutableArray *section = [sectionArray objectAtIndex:index];
			[section addObject:subReddit];
		}
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
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
	
	[mainViewController dismissPopover];
	[mainViewController viewWillAppear:YES];
}

- (IBAction)onAddButton:(id)sender {
	AddViewControllerPad *addViewController = [[AddViewControllerPad alloc] initWithNibName:@"AddViewControllerPad" bundle:nil];
	addViewController.redditsViewController = self;
	[self.navigationController pushViewController:addViewController animated:YES];
	[addViewController release];
}

// UITableViewDatasource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return categoryArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [categoryArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[sectionArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"REDDITS_VIEW_CELL";
	
	UITableViewCell *cell = [contentTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
	}
	
	NSMutableArray *section = [sectionArray objectAtIndex:indexPath.section];
	SubRedditItem *subReddit = [section objectAtIndex:indexPath.row];
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
	
	NSMutableArray *section = [sectionArray objectAtIndex:indexPath.section];
	SubRedditItem *subReddit = [section objectAtIndex:indexPath.row];
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

- (void)onManualAdded {
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
	
	[mainViewController dismissPopover];
	[mainViewController viewWillAppear:YES];
}

@end
