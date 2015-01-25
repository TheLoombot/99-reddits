//
//  GifViewControllerPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoViewPad;

@interface GifViewControllerPad : UIViewController {
	IBOutlet UIWebView *webView;
	IBOutlet UIView *overlayView;
	
	NSData *_gifData;
	NSInteger width;
	NSInteger height;
	
	UITapGestureRecognizer* _tapGesture;
	
	BOOL hidden;
	
	PhotoViewPad __weak *photoView;
}

@property (nonatomic, strong) NSData *gifData;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic, weak) PhotoViewPad *photoView;

@end
