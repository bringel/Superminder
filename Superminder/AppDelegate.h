//
//  AppDelegate.h
//  Superminder
//
//  Created by Bradley Ringel on 4/28/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMTrelloClient;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showAuthenticationAlertWithCompletion:(void (^)())handler client:(SMTrelloClient *)client;

@end

