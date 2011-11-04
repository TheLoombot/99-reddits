//
//  RedditsAppDelegate.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"


@class MainViewController;
@class SA_OAuthTwitterEngine;
@class PhotoViewController;

@interface RedditsAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *_window;
	
	IBOutlet UINavigationController *mainNavigationController;
	IBOutlet MainViewController *mainViewController;
	
	NSMutableArray *subRedditsArray;
	BOOL firstRun;
	NSTimeInterval updatedTime;
	
	NSMutableSet *showedSet;
	
	UIAlertView *connectionAlertView;
	
	BOOL tweetEnabled;
	
    SA_OAuthTwitterEngine *_engine;
	
	PhotoViewController *photoViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) NSMutableArray *subRedditsArray;
@property (nonatomic) BOOL firstRun;
@property (nonatomic) NSTimeInterval updatedTime;
@property (nonatomic, assign) NSMutableSet *showedSet;
@property (nonatomic, readonly) BOOL tweetEnabled;
@property (nonatomic, readonly) SA_OAuthTwitterEngine *engine;
@property (nonatomic, assign) PhotoViewController *photoViewController;

+ (NSString *)getImageURL:(NSString *)urlString;
+ (NSString *)stringByRemoveHTML:(NSString *)string;

- (BOOL)checkNetworkReachable:(BOOL)showAlert;

- (void)loadFromDefaults;
- (void)saveToDefaults;

@end
