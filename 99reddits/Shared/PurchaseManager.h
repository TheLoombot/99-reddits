//
//  PurchaseManager.h
//  99reddits
//
//  Created by Frank Jacob on 1/6/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kProductsLoadedNotification						@"ProductsLoaded"
#define kProductPurchasedNotification					@"ProductPurchased"
#define kProductPurchaseFailedNotification				@"ProductPurchaseFailed"
#define kProductPurchaseRestoreFinishedNotification		@"ProductPurchaseResotreFinished"
#define kProductPurchaseRestoreFailedNotification		@"ProductPurchaseResotreFailed"


@interface PurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	NSSet *productIdentifiers;
	NSArray *products;
	SKProductsRequest *productsRequest;
	id delegate;
}

@property (nonatomic, assign) id delegate;
@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray *products;

+ (PurchaseManager *)sharedManager;
- (void)requestProducts;
- (void)buyProduct:(SKProduct *)product;
- (void)restorePurchases;

@end
