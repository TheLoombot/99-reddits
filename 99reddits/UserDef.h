//
//  UserDef.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_SUBREDDIT_COUNT     10

#define SUBREDDIT_FORMAT1			@"http://www.reddit.com/r/%@/.json?limit=50"
#define SUBREDDIT_FORMAT2			@"http://www.reddit.com/r/%@"

extern NSString *defaultSubRedditsNameArray[];
extern NSString *defaultSubRedditsURLArray[];

extern NSString *htmlStrings[];
extern NSString *normalStrings[];

// Facebook
extern NSString *kAppId;

// Twitter
#define kOAuthConsumerKey				@"grEwIZVG1i29zrAMxJqevA"
#define kOAuthConsumerSecret			@"ETZcVuwWdtMMgTwEb5RE1igz5AEiZh6Mfsv5Msc"
