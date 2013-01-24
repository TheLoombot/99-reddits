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
#import "UserDef.h"

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
	[categoryArray release];
	[sectionArray release];
	[nameStringsSet release];
	[manualAddedNameString release];
	
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
	
	categoryArray = [[NSMutableArray alloc] init];
	sectionArray = [[NSMutableArray alloc] init];
	nameStringsSet = [[NSMutableSet alloc] initWithSet:appDelegate.nameStringsSet];
	
	NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SubRedditsList" ofType:@"plist"]];
	for (NSDictionary *dictionary in array) {
		NSString *category = [dictionary objectForKey:@"category"];
		NSArray *staticArray = [dictionary objectForKey:@"subreddits"];
		
		[categoryArray addObject:category];
		[sectionArray addObject:staticArray];
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
	NSArray *tempSubRedditsArray = [NSArray arrayWithArray:appDelegate.subRedditsArray];
	for (SubRedditItem *subReddit in tempSubRedditsArray) {
		BOOL bExist = NO;
		for (NSString *nameString in nameStringsSet) {
			if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]] ||
				(manualAddedNameString && [[subReddit.nameString lowercaseString] isEqualToString:[manualAddedNameString lowercaseString]])) {
				bExist = YES;
				break;
			}
		}
		
		if (!bExist) {
			[mainViewController removeSubRedditOperations:subReddit];
			[appDelegate.subRedditsArray removeObject:subReddit];
		}
	}
	
	NSMutableArray *nameStringsArray = [NSMutableArray array];
	for (NSArray *section in sectionArray) {
		[nameStringsArray addObjectsFromArray:section];
	}
	
	if (manualAddedNameString) {
		BOOL bExist = NO;
		for (NSString *nameString in nameStringsArray) {
			if ([[nameString lowercaseString] isEqualToString:[manualAddedNameString lowercaseString]] && [nameStringsSet containsObject:[manualAddedNameString lowercaseString]])
				bExist = YES;
		}
		
		if (!bExist) {
			[nameStringsArray addObject:manualAddedNameString];
			[nameStringsSet addObject:[manualAddedNameString lowercaseString]];
		}
	}
	
	for (NSString *nameString in nameStringsArray) {
		if ([nameStringsSet containsObject:[nameString lowercaseString]]) {
			BOOL bExist = NO;
			for (SubRedditItem *subReddit in appDelegate.subRedditsArray) {
				if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
					bExist = YES;
					break;
				}
			}
			
			if (!bExist) {
				SubRedditItem *subReddit = [[[SubRedditItem alloc] init] autorelease];
				subReddit.nameString = nameString;
				subReddit.urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, subReddit.nameString];
				subReddit.subscribe = YES;
				[appDelegate.subRedditsArray addObject:subReddit];
				[mainViewController addSubReddit:subReddit];
			}
		}
	}
	
	[appDelegate refreshNameStringsSet];
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
	
	NSArray *section = [sectionArray objectAtIndex:indexPath.section];
	NSString *nameString = [section objectAtIndex:indexPath.row];
	cell.textLabel.text = nameString;
	if ([nameStringsSet containsObject:[nameString lowercaseString]]) {
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
	
	NSArray *section = [sectionArray objectAtIndex:indexPath.section];
	NSString *nameString = [section objectAtIndex:indexPath.row];
	if ([nameStringsSet containsObject:[nameString lowercaseString]]) {
		[nameStringsSet removeObject:[nameString lowercaseString]];
	}
	else {
		[nameStringsSet addObject:[nameString lowercaseString]];
	}
	
	UITableViewCell *cell = [contentTableView cellForRowAtIndexPath:indexPath];
	if ([nameStringsSet containsObject:[nameString lowercaseString]]) {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"CheckIcon.png"];
	}
	else {
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UncheckCellBack.png"]] autorelease];
		cell.imageView.image = [UIImage imageNamed:@"UncheckIcon.png"];
	}
}

- (void)onManualAdded:(NSString *)nameString {
	if (nameString)
		manualAddedNameString = [nameString retain];
	else
		manualAddedNameString = nil;
	[self onDoneButton:nil];
}

@end
