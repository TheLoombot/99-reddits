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

	NSMutableArray *subRedditsArray;
	NSMutableSet *nameStringsSet;
	BOOL firstRun;
	
	NSMutableSet *showedSet;
	
	UIAlertView *connectionAlertView;
	
	SubRedditItem *favoritesItem;
	NSMutableSet *favoritesSet;
	
	BOOL isPaid;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, readonly) NSMutableArray *subRedditsArray;
@property (nonatomic, readonly) NSMutableSet *nameStringsSet;
@property (nonatomic) BOOL firstRun;
@property (nonatomic, readonly) NSMutableSet *showedSet;
@property (nonatomic, readonly) SubRedditItem *favoritesItem;
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

- (void)setNavAppearance;
- (void)unsetNavAppearance;

- (void)refreshNameStringsSet;

@end
