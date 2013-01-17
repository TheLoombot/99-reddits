//
//  RedditsAppDelegate.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubRedditItem.h"
#import "PhotoItem.h"

@class MainViewController;

@interface RedditsAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UINavigationController *mainNavigationController;

	NSMutableArray *staticSubRedditsArray;
	NSMutableArray *manualSubRedditsArray;
	NSMutableArray *subRedditsArray;
	BOOL firstRun;
	
	NSMutableSet *showedSet;
	
	UIAlertView *connectionAlertView;
	
	SubRedditItem *favoritesItem;
	NSMutableSet *favoritesSet;
	
	BOOL isPaid;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, assign) NSMutableArray *staticSubRedditsArray;
@property (nonatomic, assign) NSMutableArray *manualSubRedditsArray;
@property (nonatomic, assign) NSMutableArray *subRedditsArray;
@property (nonatomic) BOOL firstRun;
@property (nonatomic, assign) NSMutableSet *showedSet;
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

- (void)setNavAppearance;
- (void)unsetNavAppearance;

@end
