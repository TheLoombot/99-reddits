//
//  MainViewLayoutPad.m
//  99reddits
//
//  Created by Frank Jacob on 1/21/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "MainViewLayoutPad.h"
#import <QuartzCore/QuartzCore.h>

#define LX_FRAMES_PER_SECOND 60.0

#ifndef CGGEOMETRY_LXSUPPORT_H_
CG_INLINE CGPoint
LXS_CGPointAdd(CGPoint thePoint1, CGPoint thePoint2) {
	return CGPointMake(thePoint1.x + thePoint2.x, thePoint1.y + thePoint2.y);
}
#endif

typedef NS_ENUM(NSInteger, MainViewLayoutPadScrollingDirection) {
	MainViewLayoutPadScrollingDirectionUp = 1,
	MainViewLayoutPadScrollingDirectionDown,
	MainViewLayoutPadScrollingDirectionLeft,
	MainViewLayoutPadScrollingDirectionRight
};

static NSString * const kMainViewLayoutPadScrollingDirectionKey = @"LXScrollingDirection";

@implementation MainViewLayoutPad

- (id)init {
	self = [super init];
	if (self) {
		self.itemSize = CGSizeMake(145, 175);
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = 0;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		if (isIOS7Below) {
			if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
				self.sectionInset = UIEdgeInsetsMake(10, 2, 15, 7);
			}
			else {
				self.sectionInset = UIEdgeInsetsMake(10, 15, 15, 20);
			}
		}
		else {
			if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
				self.sectionInset = UIEdgeInsetsMake(74, 2, 15, 7);
			}
			else {
				self.sectionInset = UIEdgeInsetsMake(74, 15, 15, 20);
			}
		}
	}
	return self;
}


- (BOOL)isEditing {
	if ([[self.collectionView.delegate class] conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
		return [(id)self.collectionView.delegate isEditingForCollectionView:self.collectionView layout:self];
	}
	return NO;
}

+ (Class)layoutAttributesClass {
	return [MainViewLayoutAttributesPad class];
}

- (MainViewLayoutAttributesPad *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	MainViewLayoutAttributesPad *attributes = (MainViewLayoutAttributesPad *)[super layoutAttributesForItemAtIndexPath:indexPath];
	attributes.editing = [attributes isEditing];
	
	switch (attributes.representedElementCategory) {
		case UICollectionElementCategoryCell: {
			[self applyLayoutAttributes:attributes];
		}
			break;
		default: {
		}
			break;
	}
	
	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
	NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
	for (UICollectionViewLayoutAttributes *attribute in attributes) {
		if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) {
			[newAttributes addObject:attribute];
		}
	}

	for (MainViewLayoutAttributesPad *attributes in newAttributes) {
		attributes.editing = [self isEditing];
		
		switch (attributes.representedElementCategory) {
			case UICollectionElementCategoryCell: {
				[self applyLayoutAttributes:attributes];
			}
				break;
			default: {
			}
				break;
		}
	}
	
	return newAttributes;
}

- (void)setUpGestureRecognizersOnCollectionView {
	UILongPressGestureRecognizer *theLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	// Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
	// by enforcing failure dependency so that they doesn't clash.
	for (UIGestureRecognizer *theGestureRecognizer in self.collectionView.gestureRecognizers) {
		if ([theGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
			[theGestureRecognizer requireGestureRecognizerToFail:theLongPressGestureRecognizer];
		}
	}
	theLongPressGestureRecognizer.delegate = self;
	[self.collectionView addGestureRecognizer:theLongPressGestureRecognizer];
	self.longPressGestureRecognizer = theLongPressGestureRecognizer;
	
	UIPanGestureRecognizer *thePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	thePanGestureRecognizer.delegate = self;
	[self.collectionView addGestureRecognizer:thePanGestureRecognizer];
	self.panGestureRecognizer = thePanGestureRecognizer;
	
	self.triggerScrollingEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
	self.scrollingSpeed = 300.0f;
	[self.scrollingTimer invalidate];
	self.scrollingTimer = nil;
	self.alwaysScroll = YES;
}

#pragma mark - Custom methods

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)theLayoutAttributes {
	if ([theLayoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
		theLayoutAttributes.hidden = YES;
	}
}

- (void)invalidateLayoutIfNecessary {
	NSIndexPath *theIndexPathOfSelectedItem = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
	if ((![theIndexPathOfSelectedItem isEqual:self.selectedItemIndexPath]) &&(theIndexPathOfSelectedItem)) {
		NSIndexPath *thePreviousSelectedIndexPath = self.selectedItemIndexPath;
		self.selectedItemIndexPath = theIndexPathOfSelectedItem;
		
		id<MainViewLayoutPadDelegate> theDelegate = (id<MainViewLayoutPadDelegate>) self.collectionView.delegate;
		
		if ([theDelegate conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
			
			// Check with the delegate to see if this move is even allowed.
			if ([theDelegate respondsToSelector:@selector(collectionView:layout:itemAtIndexPath:shouldMoveToIndexPath:)]) {
				BOOL shouldMove = [theDelegate collectionView:self.collectionView
													   layout:self
											  itemAtIndexPath:thePreviousSelectedIndexPath
										shouldMoveToIndexPath:theIndexPathOfSelectedItem];
				
				if (!shouldMove) {
					return;
				}
			}
			
			// Proceed with the move
			[theDelegate collectionView:self.collectionView
								 layout:self
						itemAtIndexPath:thePreviousSelectedIndexPath
					willMoveToIndexPath:theIndexPathOfSelectedItem];
		}
		
		[self.collectionView performBatchUpdates:^{
			//[self.collectionView moveItemAtIndexPath:thePreviousSelectedIndexPath toIndexPath:theIndexPathOfSelectedItem];
			[self.collectionView deleteItemsAtIndexPaths:@[ thePreviousSelectedIndexPath ]];
			[self.collectionView insertItemsAtIndexPaths:@[ theIndexPathOfSelectedItem ]];
		} completion:^(BOOL finished) {
		}];
	}
}

#pragma mark - Target/Action methods

- (void)handleScroll:(NSTimer *)theTimer {
	MainViewLayoutPadScrollingDirection theScrollingDirection = (MainViewLayoutPadScrollingDirection)[theTimer.userInfo[kMainViewLayoutPadScrollingDirectionKey] integerValue];
	switch (theScrollingDirection) {
		case MainViewLayoutPadScrollingDirectionUp: {
			CGFloat theDistance = -(self.scrollingSpeed / LX_FRAMES_PER_SECOND);
			CGPoint theContentOffset = self.collectionView.contentOffset;
			CGFloat theMinY = 0.0f;
			if ((theContentOffset.y + theDistance) <= theMinY) {
				theDistance = -theContentOffset.y;
			}
			self.collectionView.contentOffset = LXS_CGPointAdd(theContentOffset, CGPointMake(0.0f, theDistance));
			self.currentViewCenter = LXS_CGPointAdd(self.currentViewCenter, CGPointMake(0.0f, theDistance));
			self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
		} break;
		case MainViewLayoutPadScrollingDirectionDown: {
			CGFloat theDistance = (self.scrollingSpeed / LX_FRAMES_PER_SECOND);
			CGPoint theContentOffset = self.collectionView.contentOffset;
			CGFloat theMaxY = MAX(self.collectionView.contentSize.height, CGRectGetHeight(self.collectionView.bounds)) - CGRectGetHeight(self.collectionView.bounds);
			if ((theContentOffset.y + theDistance) >= theMaxY) {
				theDistance = theMaxY - theContentOffset.y;
			}
			self.collectionView.contentOffset = LXS_CGPointAdd(theContentOffset, CGPointMake(0.0f, theDistance));
			self.currentViewCenter = LXS_CGPointAdd(self.currentViewCenter, CGPointMake(0.0f, theDistance));
			self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
		} break;
			
		case MainViewLayoutPadScrollingDirectionLeft: {
			CGFloat theDistance = -(self.scrollingSpeed / LX_FRAMES_PER_SECOND);
			CGPoint theContentOffset = self.collectionView.contentOffset;
			CGFloat theMinX = 0.0f;
			if ((theContentOffset.x + theDistance) <= theMinX) {
				theDistance = -theContentOffset.x;
			}
			self.collectionView.contentOffset = LXS_CGPointAdd(theContentOffset, CGPointMake(theDistance, 0.0f));
			self.currentViewCenter = LXS_CGPointAdd(self.currentViewCenter, CGPointMake(theDistance, 0.0f));
			self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
		} break;
		case MainViewLayoutPadScrollingDirectionRight: {
			CGFloat theDistance = (self.scrollingSpeed / LX_FRAMES_PER_SECOND);
			CGPoint theContentOffset = self.collectionView.contentOffset;
			CGFloat theMaxX = MAX(self.collectionView.contentSize.width, CGRectGetWidth(self.collectionView.bounds)) - CGRectGetWidth(self.collectionView.bounds);
			if ((theContentOffset.x + theDistance) >= theMaxX) {
				theDistance = theMaxX - theContentOffset.x;
			}
			self.collectionView.contentOffset = LXS_CGPointAdd(theContentOffset, CGPointMake(theDistance, 0.0f));
			self.currentViewCenter = LXS_CGPointAdd(self.currentViewCenter, CGPointMake(theDistance, 0.0f));
			self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
		} break;
			
		default: {
		} break;
	}
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)theLongPressGestureRecognizer {
	switch (theLongPressGestureRecognizer.state) {
		case UIGestureRecognizerStateBegan: {
			CGPoint theLocationInCollectionView = [theLongPressGestureRecognizer locationInView:self.collectionView];
			NSIndexPath *theIndexPathOfSelectedItem = [self.collectionView indexPathForItemAtPoint:theLocationInCollectionView];
			
			if ([self.collectionView.delegate conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
				id<MainViewLayoutPadDelegate> theDelegate = (id<MainViewLayoutPadDelegate>)self.collectionView.delegate;
				if ([theDelegate respondsToSelector:@selector(collectionView:layout:shouldBeginReorderingAtIndexPath:)]) {
					BOOL shouldStartReorder =  [theDelegate collectionView:self.collectionView layout:self shouldBeginReorderingAtIndexPath:theIndexPathOfSelectedItem];
					if (!shouldStartReorder) {
						return;
					}
				}
				
				if ([theDelegate respondsToSelector:@selector(collectionView:layout:willBeginReorderingAtIndexPath:)]) {
					[theDelegate collectionView:self.collectionView layout:self willBeginReorderingAtIndexPath:theIndexPathOfSelectedItem];
				}
			}
			
			UICollectionViewCell *theCollectionViewCell = [self.collectionView cellForItemAtIndexPath:theIndexPathOfSelectedItem];
			
			UIGraphicsBeginImageContext(theCollectionViewCell.bounds.size);
			[theCollectionViewCell.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			UIImageView *theImageView = [[UIImageView alloc] initWithImage:theImage];
			theImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

			UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(theCollectionViewCell.frame), CGRectGetMinY(theCollectionViewCell.frame), CGRectGetWidth(theImageView.frame), CGRectGetHeight(theImageView.frame))];
			
			[theView addSubview:theImageView];
			
			[self.collectionView addSubview:theView];
			
			self.selectedItemIndexPath = theIndexPathOfSelectedItem;
			self.currentView = theView;
			self.currentViewCenter = theView.center;
			
			[UIView
			 animateWithDuration:0.3
			 animations:^{
				 theView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
			 }
			 completion:^(BOOL finished) {
				 if ([self.collectionView.delegate conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
					 id<MainViewLayoutPadDelegate> theDelegate = (id<MainViewLayoutPadDelegate>)self.collectionView.delegate;
					 if ([theDelegate respondsToSelector:@selector(collectionView:layout:didBeginReorderingAtIndexPath:)]) {
						 [theDelegate collectionView:self.collectionView layout:self didBeginReorderingAtIndexPath:theIndexPathOfSelectedItem];
					 }
				 }
			 }];
			
			[self invalidateLayout];
		} break;
		case UIGestureRecognizerStateEnded: {
			NSIndexPath *theIndexPathOfSelectedItem = self.selectedItemIndexPath;
			
			if ([self.collectionView.delegate conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
				id<MainViewLayoutPadDelegate> theDelegate = (id<MainViewLayoutPadDelegate>)self.collectionView.delegate;
				if ([theDelegate respondsToSelector:@selector(collectionView:layout:willEndReorderingAtIndexPath:)]) {
					[theDelegate collectionView:self.collectionView layout:self willEndReorderingAtIndexPath:theIndexPathOfSelectedItem];
				}
			}
			
			self.selectedItemIndexPath = nil;
			self.currentViewCenter = CGPointZero;
			
			if (theIndexPathOfSelectedItem) {
				UICollectionViewLayoutAttributes *theLayoutAttributes = [self layoutAttributesForItemAtIndexPath:theIndexPathOfSelectedItem];
				
				[UIView
				 animateWithDuration:0.3f
				 animations:^{
					 self.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
					 self.currentView.center = theLayoutAttributes.center;
				 }
				 completion:^(BOOL finished) {
					 [self.currentView removeFromSuperview];
					 self.currentView = nil;
					 [self invalidateLayout];
					 
					 if ([self.collectionView.delegate conformsToProtocol:@protocol(MainViewLayoutPadDelegate)]) {
						 id<MainViewLayoutPadDelegate> theDelegate = (id<MainViewLayoutPadDelegate>)self.collectionView.delegate;
						 if ([theDelegate respondsToSelector:@selector(collectionView:layout:didEndReorderingAtIndexPath:)]) {
							 [theDelegate collectionView:self.collectionView layout:self didEndReorderingAtIndexPath:theIndexPathOfSelectedItem];
						 }
					 }
				 }];
			}
			else {
				[self.currentView removeFromSuperview];
				self.currentView = nil;
				[self invalidateLayout];
			}
		} break;
		default: {
		} break;
	}
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)thePanGestureRecognizer {
	switch (thePanGestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStateChanged: {
			CGPoint theTranslationInCollectionView = [thePanGestureRecognizer translationInView:self.collectionView];
			self.panTranslationInCollectionView = theTranslationInCollectionView;
			CGPoint theLocationInCollectionView = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
			self.currentView.center = theLocationInCollectionView;
			
			[self invalidateLayoutIfNecessary];
			
			switch (self.scrollDirection) {
				case UICollectionViewScrollDirectionVertical: {
					if (theLocationInCollectionView.y < (CGRectGetMinY(self.collectionView.bounds) + self.triggerScrollingEdgeInsets.top)) {
						BOOL isScrollingTimerSetUpNeeded = YES;
						if (self.scrollingTimer) {
							if (self.scrollingTimer.isValid) {
								isScrollingTimerSetUpNeeded = ([self.scrollingTimer.userInfo[kMainViewLayoutPadScrollingDirectionKey] integerValue] != MainViewLayoutPadScrollingDirectionUp);
							}
						}
						if (isScrollingTimerSetUpNeeded) {
							if (self.scrollingTimer) {
								[self.scrollingTimer invalidate];
								self.scrollingTimer = nil;
							}
							self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / LX_FRAMES_PER_SECOND
																				   target:self
																				 selector:@selector(handleScroll:)
																				 userInfo:@{ kMainViewLayoutPadScrollingDirectionKey : @( MainViewLayoutPadScrollingDirectionUp ) }
																				  repeats:YES];
						}
					}
					else if (theLocationInCollectionView.y > (CGRectGetMaxY(self.collectionView.bounds) - self.triggerScrollingEdgeInsets.bottom)) {
						BOOL isScrollingTimerSetUpNeeded = YES;
						if (self.scrollingTimer) {
							if (self.scrollingTimer.isValid) {
								isScrollingTimerSetUpNeeded = ([self.scrollingTimer.userInfo[kMainViewLayoutPadScrollingDirectionKey] integerValue] != MainViewLayoutPadScrollingDirectionDown);
							}
						}
						if (isScrollingTimerSetUpNeeded) {
							if (self.scrollingTimer) {
								[self.scrollingTimer invalidate];
								self.scrollingTimer = nil;
							}
							self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / LX_FRAMES_PER_SECOND
																				   target:self
																				 selector:@selector(handleScroll:)
																				 userInfo:@{ kMainViewLayoutPadScrollingDirectionKey : @( MainViewLayoutPadScrollingDirectionDown ) }
																				  repeats:YES];
						}
					}
					else {
						if (self.scrollingTimer) {
							[self.scrollingTimer invalidate];
							self.scrollingTimer = nil;
						}
					}
				} break;
				case UICollectionViewScrollDirectionHorizontal: {
					if (theLocationInCollectionView.x < (CGRectGetMinX(self.collectionView.bounds) + self.triggerScrollingEdgeInsets.left)) {
						BOOL isScrollingTimerSetUpNeeded = YES;
						if (self.scrollingTimer) {
							if (self.scrollingTimer.isValid) {
								isScrollingTimerSetUpNeeded = ([self.scrollingTimer.userInfo[kMainViewLayoutPadScrollingDirectionKey] integerValue] != MainViewLayoutPadScrollingDirectionLeft);
							}
						}
						if (isScrollingTimerSetUpNeeded) {
							if (self.scrollingTimer) {
								[self.scrollingTimer invalidate];
								self.scrollingTimer = nil;
							}
							self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / LX_FRAMES_PER_SECOND
																				   target:self
																				 selector:@selector(handleScroll:)
																				 userInfo:@{ kMainViewLayoutPadScrollingDirectionKey : @( MainViewLayoutPadScrollingDirectionLeft ) }
																				  repeats:YES];
						}
					}
					else if (theLocationInCollectionView.x > (CGRectGetMaxX(self.collectionView.bounds) - self.triggerScrollingEdgeInsets.right)) {
						BOOL isScrollingTimerSetUpNeeded = YES;
						if (self.scrollingTimer) {
							if (self.scrollingTimer.isValid) {
								isScrollingTimerSetUpNeeded = ([self.scrollingTimer.userInfo[kMainViewLayoutPadScrollingDirectionKey] integerValue] != MainViewLayoutPadScrollingDirectionRight);
							}
						}
						if (isScrollingTimerSetUpNeeded) {
							if (self.scrollingTimer) {
								[self.scrollingTimer invalidate];
								self.scrollingTimer = nil;
							}
							self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / LX_FRAMES_PER_SECOND
																				   target:self
																				 selector:@selector(handleScroll:)
																				 userInfo:@{ kMainViewLayoutPadScrollingDirectionKey : @( MainViewLayoutPadScrollingDirectionRight ) }
																				  repeats:YES];
						}
					}
					else {
						if (self.scrollingTimer) {
							[self.scrollingTimer invalidate];
							self.scrollingTimer = nil;
						}
					}
				} break;
			}
		} break;
		case UIGestureRecognizerStateEnded: {
			if (self.scrollingTimer) {
				[self.scrollingTimer invalidate];
				self.scrollingTimer = nil;
			}
		} break;
		default: {
		} break;
	}
}

#pragma mark - UICollectionViewFlowLayoutDelegate methods

- (CGSize)collectionViewContentSize {
	CGSize theCollectionViewContentSize = [super collectionViewContentSize];
	if (self.alwaysScroll) {
		switch (self.scrollDirection) {
			case UICollectionViewScrollDirectionVertical: {
				if (theCollectionViewContentSize.height <= CGRectGetHeight(self.collectionView.bounds)) {
					theCollectionViewContentSize.height = CGRectGetHeight(self.collectionView.bounds) + 1.0f;
				}
			} break;
			case UICollectionViewScrollDirectionHorizontal: {
				if (theCollectionViewContentSize.width <= CGRectGetWidth(self.collectionView.bounds)) {
					theCollectionViewContentSize.width = CGRectGetWidth(self.collectionView.bounds) + 1.0f;
				}
			} break;
		}
	}
	return theCollectionViewContentSize;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)theGestureRecognizer {
	if ([self.panGestureRecognizer isEqual:theGestureRecognizer]) {
		return (self.selectedItemIndexPath != nil);
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)theGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)theOtherGestureRecognizer {
	if ([self.longPressGestureRecognizer isEqual:theGestureRecognizer]) {
		if ([self.panGestureRecognizer isEqual:theOtherGestureRecognizer]) {
			return YES;
		}
		else {
			return NO;
		}
	}
	else if ([self.panGestureRecognizer isEqual:theGestureRecognizer]) {
		if ([self.longPressGestureRecognizer isEqual:theOtherGestureRecognizer]) {
			return YES;
		}
		else {
			return NO;
		}
	}
	return NO;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	if (isIOS7Below) {
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			self.sectionInset = UIEdgeInsetsMake(10, 2, 15, 7);
		}
		else {
			self.sectionInset = UIEdgeInsetsMake(10, 15, 15, 20);
		}
	}
	else {
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			self.sectionInset = UIEdgeInsetsMake(74, 2, 15, 7);
		}
		else {
			self.sectionInset = UIEdgeInsetsMake(74, 15, 15, 20);
		}
	}
	return YES;
}

@end
