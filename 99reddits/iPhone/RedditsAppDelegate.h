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

@interface RedditsAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *_window;
	
	IBOutlet UINavigationController *mainNavigationController;
	IBOutlet MainViewController *mainViewController;

	NSMutableArray *staticSubRedditsArray;
	NSMutableArray *manualSubRedditsArray;
	NSMutableArray *subRedditsArray;
	BOOL firstRun;
	
	NSMutableSet *showedSet;
	
	UIAlertView *connectionAlertView;
	
	BOOL tweetEnabled;
	
    SA_OAuthTwitterEngine *_engine;
	
	SubRedditItem *favoritesItem;
	NSMutableSet *favoritesSet;
	
	BOOL isPaid;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) NSMutableArray *staticSubRedditsArray;
@property (nonatomic, assign) NSMutableArray *manualSubRedditsArray;
@property (nonatomic, assign) NSMutableArray *subRedditsArray;
@property (nonatomic) BOOL firstRun;
@property (nonatomic, assign) NSMutableSet *showedSet;
@property (nonatomic, readonly) BOOL tweetEnabled;
@property (nonatomic, readonly) SA_OAuthTwitterEngine *engine;
@property (nonatomic, retain) SubRedditItem *favoritesItem;
@property (nonatomic) BOOL isPaid;


+ (NSString *)getImageURL:(NSString *)urlString;
+ (NSString *)stringByRemoveHTML:(NSString *)string;

- (BOOL)checkNetworkReachable:(BOOL)showAlert;

- (void)loadFromDefaults;
- (void)saveToDefaults;
- (void)saveFavoritesData;

- (BOOL)addToFavorites:(PhotoItem *)photo;
- (BOOL)removeFromFavorites:(PhotoItem *)photo;
- (BOOL)isFavorite:(PhotoItem *)photo;

- (void)refreshSubscribe;

@end
