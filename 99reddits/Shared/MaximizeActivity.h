//
//  MaximizeActivity.h
//  99reddits
//
//  Created by Frank J. on 1/28/15.
//  Copyright (c) 2015 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MaximizeActivityDelegate;

@interface MaximizeActivity : UIActivity {
	id<MaximizeActivityDelegate> __weak delegate;
	BOOL canPerformActivity;
}

@property (nonatomic, weak) id<MaximizeActivityDelegate> delegate;
@property (nonatomic) BOOL canPerformActivity;

@end

@protocol MaximizeActivityDelegate <NSObject>

- (void)performMaximize;

@end
