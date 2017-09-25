//
//  CommentViewController.h
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
  
	NSString *urlString;
	BOOL loading;
}

@property (nonatomic, copy) NSString *urlString;

- (IBAction)onCloseButton:(id)sender;
- (IBAction)onShareButton:(id)sender;

@end
