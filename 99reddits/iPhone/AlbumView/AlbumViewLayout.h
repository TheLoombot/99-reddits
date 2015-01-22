//
//  AlbumViewLayout.h
//  99reddits
//
//  Created by Frank Jacob on 6/14/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewLayout : UICollectionViewFlowLayout {
	NSInteger cellCount;
	NSMutableArray *deleteIndexPaths;
	NSMutableArray *insertIndexPaths;
}

@end
