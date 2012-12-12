//
//  UserDef.h
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SUBREDDIT_FORMAT1				@"http://www.reddit.com/r/%@/.json?limit=50"
#define SUBREDDIT_FORMAT2				@"http://www.reddit.com/r/%@"

#define NEW_SUBREDDIT_FORMAT			@"http://www.reddit.com/r/%@/new.json?limit=50&sort=new"
#define CONTROVERSIAL_SUBREDDIT_FORMAT	@"http://www.reddit.com/r/%@/controversial.json?limit=50"
#define TOP_SUBREDDIT_FORMAT			@"http://www.reddit.com/r/%@/top.json?sort=top&t=all&limit=50"

extern NSString *htmlStrings[];
extern NSString *normalStrings[];

// Facebook
extern NSString *kAppId;

// Twitter
#define kOAuthConsumerKey				@"grEwIZVG1i29zrAMxJqevA"
#define kOAuthConsumerSecret			@"ETZcVuwWdtMMgTwEb5RE1igz5AEiZh6Mfsv5Msc"

#define PRODUCT_ID						@"PAID_USER"

#define PORT_COL_COUNT					5
#define LAND_COL_COUNT					7
