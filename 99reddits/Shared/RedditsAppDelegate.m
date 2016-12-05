//
//  RedditsAppDelegate.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "RedditsAppDelegate.h"
#import "UserDef.h"
#import "Reachability.h"
#import "Flurry.h"
//#import <Crashlytics/Crashlytics.h>

@implementation UINavigationController (iOS6OrientationFix)

- (BOOL)shouldAutorotate {
	return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@implementation RedditsAppDelegate

@synthesize window = _window;
@synthesize subRedditsArray;
@synthesize nameStringsSet;
@synthesize showedSet;
@synthesize firstRun;
@synthesize favoritesItem;
@synthesize isPaid;

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setStatusBarHidden:NO];
	
	appDelegate = self;
	
	screenWidth = [[UIScreen mainScreen] bounds].size.width;
	screenHeight = [[UIScreen mainScreen] bounds].size.height;
	if (screenWidth > screenHeight) {
		CGFloat temp = screenWidth;
		screenWidth = screenHeight;
		screenHeight = temp;
	}
	screenScale = [[UIScreen mainScreen] scale];
	isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);

	self.window.backgroundColor = [UIColor whiteColor];
	mainNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	mainNavigationController.navigationBar.translucent = YES;

//    [Crashlytics startWithAPIKey:@"7228ed62a7b305f3ee6ec449adbda49637b3168a"];
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

	[Flurry startSession:@"29Y8B1XXMBQVLEPC3ZPU"];

	subRedditsArray = [[NSMutableArray alloc] init];
	nameStringsSet = [[NSMutableSet alloc] init];
	showedSet = [[NSMutableSet alloc] init];
	fullImagesSet = [[NSMutableSet alloc] init];
	
	[self loadFromDefaults];

	self.window.rootViewController = mainNavigationController;
	[self.window makeKeyAndVisible];

	[Appirater setAppId:@"474846610"];
	[Appirater setDaysUntilPrompt:2];
	[Appirater setUsesUntilPrompt:5];
	[Appirater setSignificantEventsUntilPrompt:3];
	[Appirater setTimeBeforeReminding:7];
	[Appirater setDebug:NO];
	[Appirater appLaunched:NO];
    [Appirater setOpenInAppStore:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self saveToDefaults];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[Appirater appEnteredForeground:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self checkNetworkReachable:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveToDefaults];
}

- (void)loadFromDefaults {
	firstRun = NO;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:@"DATA_VERSION"]) {
		NSData *data = [defaults objectForKey:@"SUBREDDITS"];
		if (data != nil) {
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			NSArray *array = [unarchiver decodeObjectForKey:@"data"];
			[unarchiver finishDecoding];
			[subRedditsArray addObjectsFromArray:array];
		}

		float version = [[defaults objectForKey:@"DATA_VERSION"] floatValue];
		if (version < [DATA_VERSION floatValue]) {
			NSArray *subscribeNamesArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SubscribeList" ofType:@"plist"]];
			for (NSString *nameString in subscribeNamesArray) {
				BOOL bExist = NO;
				for (SubRedditItem *subReddit in subRedditsArray) {
					if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
						bExist = YES;
						break;
					}
				}
				
				if (!bExist) {
					SubRedditItem *subReddit = [[SubRedditItem alloc] init];
					subReddit.nameString = nameString;
					subReddit.urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, subReddit.nameString];
					subReddit.subscribe = YES;
					[subRedditsArray addObject:subReddit];
				}
			}
		}
	}
	else {
		NSData *data = [defaults objectForKey:@"STATIC_SUBREDDITS"];
		if (data != nil) {
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			NSArray *array = [unarchiver decodeObjectForKey:@"data"];
			[unarchiver finishDecoding];
			for (SubRedditItem *subReddit in array) {
				if (subReddit.subscribe)
					[subRedditsArray addObject:subReddit];
			}
			
			[defaults removeObjectForKey:@"STATIC_SUBREDDITS"];
			
			data = [defaults objectForKey:@"MANUAL_SUBREDDITS"];
			if (data != nil) {
				NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
				NSArray *array = [unarchiver decodeObjectForKey:@"data"];
				[unarchiver finishDecoding];
				for (SubRedditItem *subReddit in array) {
					if (subReddit.subscribe)
						[subRedditsArray addObject:subReddit];
				}
			}
			
			[defaults removeObjectForKey:@"MANUAL_SUBREDDITS"];
		}
		else {
			NSArray *subscribeNamesArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SubscribeList" ofType:@"plist"]];
			for (NSString *nameString in subscribeNamesArray) {
				BOOL bExist = NO;
				for (SubRedditItem *subReddit in subRedditsArray) {
					if ([[subReddit.nameString lowercaseString] isEqualToString:[nameString lowercaseString]]) {
						bExist = YES;
						break;
					}
				}
				
				if (!bExist) {
					SubRedditItem *subReddit = [[SubRedditItem alloc] init];
					subReddit.nameString = nameString;
					subReddit.urlString = [NSString stringWithFormat:SUBREDDIT_FORMAT1, subReddit.nameString];
					subReddit.subscribe = YES;
					[subRedditsArray addObject:subReddit];
				}
			}
			
			firstRun = YES;
		}
	}
	
	[defaults setObject:DATA_VERSION forKey:@"DATA_VERSION"];
	[defaults synchronize];

	[self refreshNameStringsSet];
	
	NSArray *array = [defaults objectForKey:@"SHOWEDSET"];
	if (array)
		[showedSet addObjectsFromArray:array];
	
	for (SubRedditItem *subReddit in subRedditsArray) {
		[subReddit calUnshowedCount];
	}

	array = [defaults objectForKey:@"FULL_IMAGES"];
	if (array)
		[fullImagesSet addObjectsFromArray:array];

	NSData *favoritesData = [defaults objectForKey:@"FAVORITES_ITEM"];
	if (favoritesData) {
		NSKeyedUnarchiver *favoritesUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:favoritesData];
		favoritesItem = [favoritesUnarchiver decodeObjectForKey:@"data"];
		[favoritesUnarchiver finishDecoding];
		favoritesSet = [[NSMutableSet alloc] initWithArray:[defaults objectForKey:@"FAVORITES_SET"]];
	}
	
	if (favoritesItem == nil) {
		favoritesItem = [[SubRedditItem alloc] init];
		favoritesSet = [[NSMutableSet alloc] init];
	}

	favoritesItem.nameString = @"Favorites";
	
	isPaid = [defaults boolForKey:@"IS_PAID"];
}

- (void)saveToDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:subRedditsArray forKey:@"data"];
	[archiver finishEncoding];
	[defaults setObject:data forKey:@"SUBREDDITS"];
	
	[defaults setObject:[showedSet allObjects] forKey:@"SHOWEDSET"];
	[defaults setObject:[fullImagesSet allObjects] forKey:@"FULL_IMAGES"];
	
	[defaults setBool:isPaid forKey:@"IS_PAID"];
	
	[defaults synchronize];
	
	[self saveFavoritesData];
}

- (void)saveFavoritesData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableData *favoritesData = [[NSMutableData alloc] init];
	NSKeyedArchiver *favoritesArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:favoritesData];
	[favoritesArchiver encodeObject:favoritesItem forKey:@"data"];
	[favoritesArchiver finishEncoding];
	[defaults setObject:favoritesData forKey:@"FAVORITES_ITEM"];
	
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
    
    // NSLog(@"URLString: %@", urlString);
    
    // hacky crash fix possibly for the case where content is removed for violating
    // reddit's content policies instead of normal deletion
    if ((id)urlString == [NSNull null])
        return @"";
    
	if ([urlString hasPrefix:@"http://imgur.com/a/"])
		return @"";
	
	urlString = [RedditsAppDelegate stringByRemoveHTML:urlString];
	
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
        if ([[[urlString lastPathComponent] stringByDeletingPathExtension] length] == 5 ||
			[[[urlString lastPathComponent] stringByDeletingPathExtension] length] == 7) {
            urlString = [[NSString stringWithFormat:@"http://i.imgur.com/%@.", 
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
	
	for (NSInteger i = 0; i < 171; i ++) {
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

// Favorites
- (BOOL)addToFavorites:(PhotoItem *)photo {
	if ([self isFavorite:photo])
		return NO;
	
	[favoritesItem.photosArray insertObject:photo atIndex:0];
	[favoritesSet addObject:photo.idString];
	
	[self saveFavoritesData];
	
	return YES;
}

- (BOOL)removeFromFavorites:(PhotoItem *)photo {
	if (![self isFavorite:photo])
		return NO;
	
	for (NSInteger i = 0; i < favoritesItem.photosArray.count; i ++) {
		PhotoItem *item = [favoritesItem.photosArray objectAtIndex:i];
		if ([item.idString isEqualToString:photo.idString]) {
			[favoritesItem.photosArray removeObject:item];
			[favoritesSet removeObject:photo.idString];
			return YES;
		}
	}
	
	[self saveFavoritesData];
	
	return NO;
}

- (BOOL)isFavorite:(PhotoItem *)photo {
	if ([favoritesSet containsObject:photo.idString])
		return YES;
	
	return NO;
}

- (void)clearFavorites {
	[favoritesItem.photosArray removeAllObjects];
	[favoritesSet removeAllObjects];

	[self saveFavoritesData];
}

- (void)refreshNameStringsSet {
	[nameStringsSet removeAllObjects];
	for (SubRedditItem *subReddit in subRedditsArray) {
		[nameStringsSet addObject:[subReddit.nameString lowercaseString]];
	}
}

- (NSString *)getFavoritesEmailString {
	NSString *htmlString = @"<html>\n<head>\n</head>\n<body>";

	for (PhotoItem *photo in favoritesItem.photosArray) {
		NSString *thumbnailString = photo.thumbnailString;

        if ([photo.urlString hasPrefix:@"http://i.imgur.com/"] || [photo.urlString hasPrefix:@"http://imgur.com/"]) {
			NSString *lastComp = [photo.urlString lastPathComponent];
			thumbnailString = [NSString stringWithFormat:@"http://i.imgur.com/%@t.png", [lastComp stringByDeletingPathExtension]];
		}

		htmlString = [htmlString stringByAppendingFormat:@"\n<p><a href=\"http://redd.it/%@\">%@</a><br /><a href=\"%@\"><img src=\"%@\" /></a></p>", photo.idString, photo.titleString, photo.urlString, thumbnailString];
	}

	htmlString = [htmlString stringByAppendingString:@"\n</body>\n</html>"];

	return htmlString;
}

- (BOOL)isFullImage:(NSString *)urlString {
	if ([urlString hasPrefix:@"http://imgur.com/"]   ||
		[urlString hasPrefix:@"http://i.imgur.com/"] ||
		[urlString hasPrefix:@"http://www.imgur.com"]) {
		return [fullImagesSet containsObject:urlString];
	}

	return YES;
}

- (void)addToFullImagesSet:(NSString *)urlString {
	[fullImagesSet addObject:urlString];
}

- (NSString *)getHugeImage:(NSString *)urlString {
    if ([urlString hasPrefix:@"http://imgur.com/"]   ||
        [urlString hasPrefix:@"http://i.imgur.com/"] ||
        [urlString hasPrefix:@"http://www.imgur.com"]) {
        if ([[[urlString lastPathComponent] stringByDeletingPathExtension] length] == 5 ||
			[[[urlString lastPathComponent] stringByDeletingPathExtension] length] == 7) {
            urlString = [[NSString stringWithFormat:@"http://i.imgur.com/%@h.",
                          [[urlString lastPathComponent] stringByDeletingPathExtension]]
                         stringByAppendingString:[urlString pathExtension]];
        }
    }

	return urlString;
}

@end
