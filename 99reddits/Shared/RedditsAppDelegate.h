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
#import "Appirater.h"
#import "CustomNavigationController.h"

@class MainViewController;

@interface RedditsAppDelegate : NSObject <UIApplicationDelegate, AppiraterDelegate> {
	IBOutlet CustomNavigationController *mainNavigationController;

	NSMutableArray *subRedditsArray;
	NSMutableSet *nameStringsSet;
	BOOL firstRun;
	
	NSMutableSet *showedSet;
	
	UIAlertView *connectionAlertView;
	
	SubRedditItem *favoritesItem;
	NSMutableSet *favoritesSet;
	
	BOOL isPaid;

	NSMutableSet *fullImagesSet;
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
- (void)clearFavorites;

- (void)refreshNameStringsSet;

- (NSString *)getFavoritesEmailString;

- (BOOL)isFullImage:(NSString *)urlString;
- (void)addToFullImagesSet:(NSString *)urlString;
- (NSString *)getHugeImage:(NSString *)urlString;

@end
