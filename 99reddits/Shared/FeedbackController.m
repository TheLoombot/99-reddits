//
//  FeedbackController.m
//  99reddits
//
//  Created by Pietro Rea on 10/7/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

@import UIKit;
@import MessageUI;
#import "FeedbackController.h"

@interface FeedbackController() <MFMailComposeViewControllerDelegate>

@end

@implementation FeedbackController

- (void)presentFeedbackViewController:(UIViewController *)presenter {

    if (![MFMailComposeViewController canSendMail]) {
        [self presentAlertViewController:presenter];
        return;
    }

    NSString *contentString = [NSString stringWithFormat:@"\n\n\n---\n99 reddits v%@\n%@ / iOS %@",
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                               deviceName(),
                               [[UIDevice currentDevice] systemVersion]];

    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;

    [mailComposeViewController setSubject:@"99 reddits feedback"];
    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"99reddits@lensie.com"]];
    [mailComposeViewController setMessageBody:contentString isHTML:NO];

    [presenter presentViewController:mailComposeViewController animated:YES completion:nil];
}

- (void)presentAlertViewController:(UIViewController *)presenter {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cannot send email" message:@"Your device is not configured to set email." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alertController addAction:action];

    [presenter presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
