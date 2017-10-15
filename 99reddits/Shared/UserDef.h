//
//  UserDef.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedditsAppDelegate.h"

#define SUBREDDIT_FORMAT1				@"https://www.reddit.com/r/%@/.json?limit=50"
#define SUBREDDIT_FORMAT2				@"https://www.reddit.com/r/%@"

#define NEW_SUBREDDIT_FORMAT			@"https://www.reddit.com/r/%@/new.json?limit=50&sort=new"
#define CONTROVERSIAL_SUBREDDIT_FORMAT	@"https://www.reddit.com/r/%@/controversial.json?limit=50"
#define TOP_SUBREDDIT_FORMAT			@"https://www.reddit.com/r/%@/top.json?sort=top&t=all&limit=50"

#define PRODUCT_ID						@"PAID_USER"

#define DATA_VERSION					@"1.0"

extern RedditsAppDelegate *appDelegate;
extern NSString *htmlStrings[];
extern NSString *normalStrings[];
extern CGFloat screenScale;
extern BOOL isPad;

extern NSString *deviceName();
