//
//  RedditsAppDelegate.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RedditsAppDelegate.h"
#import "MainViewController.h"
#import "UserDef.h"
#import "Reachability.h"
#import "SA_OAuthTwitterEngine.h"


@implementation RedditsAppDelegate

@synthesize window = _window;
@synthesize subRedditsArray;
@synthesize showedSet;
@synthesize firstRun;
@synthesize updatedTime;
@synthesize tweetEnabled;
@synthesize engine = _engine;
@synthesize photoViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	tweetEnabled = NO;
	Class tweetClass = (NSClassFromString(@"TWTweetComposeViewController"));
	if (tweetClass != nil) {
		tweetEnabled = YES;
	}
	else {
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        _engine.consumerKey    = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;
	}
	
	subRedditsArray = [[NSMutableArray alloc] init];
	
	[self loadFromDefaults];
	
	[self.window addSubview:mainNavigationController.view];
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[self saveToDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self checkNetworkReachable:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveToDefaults];
}

- (void)dealloc {
	[subRedditsArray release];
	[showedSet release];
	[connectionAlertView release];
	[_engine release];
	[_window release];
    [super dealloc];
}

- (void)loadFromDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([[defaults objectForKey:@"INITIALIZTED"] length] != 0) {
		NSData *data = [defaults objectForKey:@"subreddits"];
		if (data != nil) {
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			NSArray *array = [unarchiver decodeObjectForKey:@"data"];
			[unarchiver finishDecoding];
			[subRedditsArray addObjectsFromArray:array];
			[unarchiver release];
		}
	
		showedSet = [[NSMutableSet alloc] init];
		
		NSArray *array = [defaults objectForKey:@"SHOWEDSET"];
		if (array)
			[showedSet addObjectsFromArray:array];

		for (SubRedditItem *subReddit in subRedditsArray) {
			[subReddit calUnshowedCount];
		}
		
		firstRun = NO;
	}
	else {
		[defaults setObject:@"YES" forKey:@"INITIALIZTED"];
		[defaults synchronize];
		
		for (int i = 0; i < DEFAULT_SUBREDDIT_COUNT; i ++) {
			SubRedditItem *subReddit = [[SubRedditItem alloc] init];
			subReddit.nameString = defaultSubRedditsNameArray[i];
			subReddit.urlString = defaultSubRedditsURLArray[i];
			[subRedditsArray addObject:subReddit];
			[subReddit release];
		}
		
		showedSet = [[NSMutableSet alloc] init];
		
		firstRun = YES;
	}
	
	updatedTime = [defaults doubleForKey:@"UPDATE_TIME"];
}

- (void)saveToDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:subRedditsArray forKey:@"data"];
	[archiver finishEncoding];
	[defaults setObject:data forKey:@"subreddits"];
	[archiver release];
	[data release];
	
	[defaults setDouble:updatedTime forKey:@"UPDATE_TIME"];
	
	[defaults setObject:[showedSet allObjects] forKey:@"SHOWEDSET"];
	
	[defaults synchronize];
}

+ (NSString *)stringByRemoveUnnecessaryString:(NSString *)urlString {
	NSString *string = urlString;
	NSString *lastComponent;
	
	while (TRUE) {
		lastComponent = [string lastPathComponent];
		if ([lastComponent hasPrefix:@"#"])
			string = [string substringToIndex:string.length - lastComponent.length];
		else
			break;
	}
	
	NSArray *array = [lastComponent componentsSeparatedByString:@"#"];
	array = [[array objectAtIndex:0] componentsSeparatedByString:@"?"];
	return [array objectAtIndex:0];
}

+ (NSString *)getImageURL:(NSString *)urlString {
	if ([urlString hasPrefix:@"http://imgur.com/a/"])
		return @"";
	
	if ([urlString hasSuffix:@"/"]) {
		urlString = [urlString substringToIndex:urlString.length - 1];
	}
	
	if ([urlString hasPrefix:@"/"]) {
		urlString = [NSString stringWithFormat:@"http://www.reddit.com%@", urlString];
	}
	
	if ([urlString hasPrefix:@"http://i.imgur.com/"] && [[urlString pathExtension] length] == 0) {
		urlString = [urlString stringByAppendingString:@".jpg"];
	}

	if ([urlString hasPrefix:@"http://imgur.com/"] && [[urlString pathExtension] length] == 0) {
		urlString = [NSString stringWithFormat:@"http://i.imgur.com/%@.jpg", [RedditsAppDelegate stringByRemoveUnnecessaryString:urlString]];
	}

	if ([urlString hasPrefix:@"http://qkme.me/"] && [[urlString pathExtension] length] == 0) {
		urlString = [NSString stringWithFormat:@"http://i.qkme.me/%@.jpg", [RedditsAppDelegate stringByRemoveUnnecessaryString:urlString]];
	}

	if ([urlString hasPrefix:@"http://www.quickmeme.com/meme/"]) {
		urlString = [NSString stringWithFormat:@"http://i.qkme.me/%@.jpg", [RedditsAppDelegate stringByRemoveUnnecessaryString:urlString]];
	}

	return urlString;
}

+ (NSString *)stringByRemoveHTML:(NSString *)string {
	NSString *result = string;
	
	for (int i = 0; i < 171; i ++) {
		result = [result stringByReplacingOccurrencesOfString:htmlStrings[i] withString:normalStrings[i]];
	}
	
	return result;
}

- (BOOL)checkNetworkReachable:(BOOL)showAlert {
	BOOL bRet = ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
	if (!bRet)
		bRet = ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
	
	if (connectionAlertView == nil)
		connectionAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	if (showAlert && !bRet && !connectionAlertView.visible) {
		[connectionAlertView show];
	}
	
	return bRet;
}

// SA_OAuthTwitterEngineDelegate
- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:@"TWITTER_AUTH_DATA"];
	[defaults synchronize];
}

- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"TWITTER_AUTH_DATA"];
}

// MGTwitterEngineDelegate
- (void)requestSucceeded:(NSString *)requestIdentifier {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTER_SUCCESS" object:nil];
}

- (void)requestFailed:(NSString *)requestIdentifier withError: (NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTER_FAILED" object:nil];
}

@end
