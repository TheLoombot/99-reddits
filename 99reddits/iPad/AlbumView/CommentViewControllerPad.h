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
	IBOutlet UIToolbar *leftItem;
	IBOutlet UIToolbar *rightItem;
	IBOutlet UIWebView *webView;
	IBOutlet UIView *titleView;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *urlLabel;

	BOOL loading;

	UIActionSheet *actionSheet;
	UITapGestureRecognizer *actionSheetTapGesture;
}

@property (nonatomic, retain) NSString *urlString;

- (IBAction)onCloseButton:(id)sender;
- (IBAction)onShareButton:(id)sender;

@end
