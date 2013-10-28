//
//  MainViewLayoutPad.h
//  99reddits
//
//  Created by Frank Jacob on 1/21/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewLayoutAttributesPad.h"

@class MainViewLayoutPad;

@protocol MainViewLayoutPadDelegate <UICollectionViewDelegateFlowLayout>

- (BOOL)isEditingForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout;
- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath willMoveToIndexPath:(NSIndexPath *)theToIndexPath;

@optional

- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath shouldMoveToIndexPath:(NSIndexPath *)theToIndexPath;
- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout shouldBeginReorderingAtIndexPath:(NSIndexPath *)theIndexPath;

- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout willBeginReorderingAtIndexPath:(NSIndexPath *)theIndexPath;
- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout didBeginReorderingAtIndexPath:(NSIndexPath *)theIndexPath;
- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout willEndReorderingAtIndexPath:(NSIndexPath *)theIndexPath;
- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout didEndReorderingAtIndexPath:(NSIndexPath *)theIndexPath;

@end

@interface MainViewLayoutPad : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (assign, nonatomic) UIEdgeInsets triggerScrollingEdgeInsets;
@property (assign, nonatomic) CGFloat scrollingSpeed;
@property (strong, nonatomic) NSTimer *scrollingTimer;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;
@property (strong, nonatomic) UIView *currentView;
@property (assign, nonatomic) CGPoint currentViewCenter;
@property (assign, nonatomic) CGPoint panTranslationInCollectionView;

@property (assign, nonatomic) BOOL alwaysScroll;

- (void)setUpGestureRecognizersOnCollectionView;

@end
