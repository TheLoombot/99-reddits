//
//  PurchaseManager.m
//  99reddits
//
//  Created by Frank Jacob on 1/6/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PurchaseManager.h"

@implementation PurchaseManager

static PurchaseManager *_sharedManager;

@synthesize productIdentifiers;
@synthesize products;
@synthesize delegate;

+ (PurchaseManager *)sharedManager {
    
    if (_sharedManager != nil) {
        return _sharedManager;
    }
    _sharedManager = [[PurchaseManager alloc] init];
    return _sharedManager;
}

- (id)init {
	self = [super init];
	if (self) {
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	
	return self;
}

- (void)requestProducts {
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	self.products = response.products;
	[productsRequest release];
	productsRequest = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:products];    
}

- (void)provideContent:(NSString *)productIdentifier {
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
	[self provideContent:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
	[self provideContent:transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseRestoreFinishedNotification object:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseRestoreFailedNotification object:error];
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchases {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)dealloc {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[productIdentifiers release];
	[products release];
	[productsRequest release];
	[super dealloc];
}

@end
