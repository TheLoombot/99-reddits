//
//  AlbumViewCellItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"


@interface AlbumViewCellItem : UIButton {
	PhotoItem *photo;
	
	UIImageView *overlayView;
}

@property (nonatomic, retain) PhotoItem *photo;

@end
