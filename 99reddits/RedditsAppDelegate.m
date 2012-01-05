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
@synthesize allSubRedditsArray;
@synthesize subRedditsArray;
@synthesize showedSet;
@synthesize firstRun;
@synthesize updatedTime;
@synthesize tweetEnabled;
@synthesize engine = _engine;
@synthesize photoViewController;
@synthesize favoritesItem;

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
	
	allSubRedditsArray = [[NSMutableArray alloc] init];
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
	[favoritesItem release];
	[favoritesSet release];
	[allSubRedditsArray release];
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
		if ([[defaults objectForKey:@"UPDATED_SUBREDDITS_LIST"] length] != 0) {
			NSData *data = [defaults objectForKey:@"subreddits"];
			if (data != nil) {
				NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
				NSArray *array = [unarchiver decodeObjectForKey:@"data"];
				[unarchiver finishDecoding];
				[allSubRedditsArray addObjectsFromArray:array];
				[unarchiver release];
			}
			
			[self refreshSubscribe];
		}
		else {
			[defaults setObject:@"YES" forKey:@"UPDATED_SUBREDDITS_LIST"];
			[defaults synchronize];
			
			NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SubReddits" ofType:@"plist"]];
			
			for (int i = 0; i < array.count; i ++) {
				SubRedditItem *subReddit = [[SubRedditItem alloc] init];
				subReddit.nameString = [array objectAtIndex:i];
				subReddit.urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, subReddit.nameString];
				subReddit.subscribe = NO;
				[allSubRedditsArray addObject:subReddit];
				[subReddit release];
			}
			
			NSMutableArray *tempSubRedditsArray = [[NSMutableArray alloc] init];
			NSData *data = [defaults objectForKey:@"subreddits"];
			if (data != nil) {
				NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
				NSArray *array = [unarchiver decodeObjectForKey:@"data"];
				[unarchiver finishDecoding];
				[tempSubRedditsArray addObjectsFromArray:array];
				[unarchiver release];
			}
			
			for (SubRedditItem *subReddit in tempSubRedditsArray) {
				BOOL bExist = NO;
				for (SubRedditItem *tempSubReddit in allSubRedditsArray) {
					if ([[subReddit.nameString lowercaseString] isEqualToString:[tempSubReddit.nameString lowercaseString]]) {
						bExist = YES;
						tempSubReddit.subscribe = YES;
						break;
					}
				}
				
				if (!bExist) {
					subReddit.subscribe = YES;
					[allSubRedditsArray addObject:subReddit];
				}
			}
			
			[tempSubRedditsArray release];
			
			[self refreshSubscribe];
		}
	
		showedSet = [[NSMutableSet alloc] init];
		
		NSArray *array = [defaults objectForKey:@"SHOWEDSET"];
		if (array)
			[showedSet addObjectsFromArray:array];

		for (SubRedditItem *subReddit in allSubRedditsArray) {
			[subReddit calUnshowedCount];
		}
		
		NSData *favoritesData = [defaults objectForKey:@"FAVORITES_ITEM"];
		if (favoritesData) {
			NSKeyedUnarchiver *favoritesUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:favoritesData];
			favoritesItem = [[favoritesUnarchiver decodeObjectForKey:@"data"] retain];
			[favoritesUnarchiver finishDecoding];
			[favoritesUnarchiver release];
			favoritesSet = [[NSMutableSet alloc] initWithArray:[defaults objectForKey:@"FAVORITES_SET"]];
		}
		else {
			favoritesItem = [[SubRedditItem alloc] init];
			favoritesItem.nameString = @"Favorites";
			favoritesSet = [[NSMutableSet alloc] init];
		}
		
		firstRun = NO;
	}
	else {
		[defaults setObject:@"YES" forKey:@"INITIALIZTED"];
		[defaults synchronize];
		
		NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SubReddits" ofType:@"plist"]];
		
		for (int i = 0; i < array.count; i ++) {
			SubRedditItem *subReddit = [[SubRedditItem alloc] init];
			subReddit.nameString = [array objectAtIndex:i];
			subReddit.urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, subReddit.nameString];
			subReddit.subscribe = YES;
			[allSubRedditsArray addObject:subReddit];
			[subReddit release];
		}
		
		[self refreshSubscribe];
		
		showedSet = [[NSMutableSet alloc] init];
		
		favoritesItem = [[SubRedditItem alloc] init];
		favoritesItem.nameString = @"Favorites";
		favoritesSet = [[NSMutableSet alloc] init];
		
		firstRun = YES;
	}
	
	updatedTime = [defaults doubleForKey:@"UPDATE_TIME"];
}

- (void)saveToDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:allSubRedditsArray forKey:@"data"];
	[archiver finishEncoding];
	[defaults setObject:data forKey:@"subreddits"];
	[archiver release];
	[data release];
	
	[defaults setDouble:updatedTime forKey:@"UPDATE_TIME"];
	
	[defaults setObject:[showedSet allObjects] forKey:@"SHOWEDSET"];
	
	NSMutableData *favoritesData = [[NSMutableData alloc] init];
	NSKeyedArchiver *favoritesArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:favoritesData];
	[favoritesArchiver encodeObject:favoritesItem forKey:@"data"];
	[favoritesArchiver finishEncoding];
	[defaults setObject:favoritesData forKey:@"FAVORITES_ITEM"];
	[favoritesArchiver release];
	[favoritesData release];
	
	[defaults setObject:[favoritesSet allObjects] forKey:@"FAVORITES_SET"];
	
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

// This whole function should be re-written to handle the URL strings as NSURLs instead of Strings
// That way we can use functions like URLByDeletingPathExtension instead of stringByDeletingPathExtension
// The latter turns "http://blah" into "http:/blah" ... obviously not right
// ALSO: we should account for www.imgur.com, i.imgur.com and imgur.com equally...
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
    
    // Modifying (Aman 20-Dec-2011) to get reduced-size images from imgur
    // Orig:                      http://i.imgur.com/46dFa.jpg
    // Huge         [1024px max]: http://i.imgur.com/46dFah.jpg
    // Large        [640px max]:  http://i.imgur.com/46dFal.jpg
    // Medium       [320px max]:  http://i.imgur.com/46dFam.jpg
    // Big Square   [160x160px]:  http://i.imgur.com/46dFab.jpg
    // Thumb        [160px max]:  http://i.imgur.com/46dFat.jpg
    // Small square [90x90px]:    http://i.imgur.com/46dFas.jpg

    if ([urlString hasPrefix:@"http://imgur.com/"]   ||
        [urlString hasPrefix:@"http://i.imgur.com/"] || 
        [urlString hasPrefix:@"http://www.imgur.com"]) {
        if ([[[urlString lastPathComponent] stringByDeletingPathExtension] length] == 5) {
            urlString = [[NSString stringWithFormat:@"http://i.imgur.com/%@h.", 
                          [[urlString lastPathComponent] stringByDeletingPathExtension]] 
                         stringByAppendingString:[urlString pathExtension]];
        }
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

// Favorites
- (BOOL)addToFavorites:(PhotoItem *)photo {
	if ([self isFavorite:photo])
		return NO;
	
	[favoritesItem.photosArray insertObject:photo atIndex:0];
	[favoritesSet addObject:photo.idString];
	
	return YES;
}

- (BOOL)removeFromFavorites:(PhotoItem *)photo {
	if (![self isFavorite:photo])
		return NO;
	
	for (int i = 0; i < favoritesItem.photosArray.count; i ++) {
		PhotoItem *item = [favoritesItem.photosArray objectAtIndex:i];
		if ([item.idString isEqualToString:photo.idString]) {
			[favoritesItem.photosArray removeObject:item];
			[favoritesSet removeObject:photo.idString];
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isFavorite:(PhotoItem *)photo {
	if ([favoritesSet containsObject:photo.idString])
		return YES;
	
	return NO;
}

- (void)refreshSubscribe {
	[subRedditsArray removeAllObjects];
	
	for (SubRedditItem *subReddit in allSubRedditsArray) {
		if (subReddit.subscribe)
			[subRedditsArray addObject:subReddit];
	}
}

@end
