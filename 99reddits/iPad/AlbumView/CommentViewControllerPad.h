//
//  CommentViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 6/11/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewControllerPad : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	NSString *urlString;

	IBOutlet UINavigationItem *navItem;
	IBOutlet UIBarButtonItem *shareItem;
	IBOutlet UIWebView *webView;

	UIActionSheet *actionSheet;
}

@property (nonatomic, retain) NSString *urlString;

- (IBAction)onCloseButton:(id)sender;
- (IBAction)onShareButton:(id)sender;

@end
