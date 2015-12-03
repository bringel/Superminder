//
//  AppDelegate.m
//  Superminder
//
//  Created by Bradley Ringel on 4/28/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "AppDelegate.h"
#import "SMRemindersViewController.h"
#import "SMTrelloClient.h"
#import "Lockbox.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:(0.0/255.0) green:(194.0/255.0) blue:(224.0/255.0) alpha:1.0];
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *tokenFragment = url.fragment;
    NSArray *fragmentPieces = [tokenFragment componentsSeparatedByString:@"="];
    if([fragmentPieces[0] isEqualToString:@"token"]){
        [Lockbox setString:fragmentPieces[1] forKey:kTrelloUserKey];
        [[SMTrelloClient sharedClient] setNeedsReauthentication:NO];
        
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        UIViewController *topView = navController.topViewController;
        if([topView.presentedViewController isKindOfClass:NSClassFromString(@"SFSafariViewController")]){
            [topView dismissViewControllerAnimated:YES completion:nil];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SuperminderHasLaunched"];
    }
    return YES;
}

- (void)showAuthenticationAlertWithCompletion:(void (^)())handler client:(SMTrelloClient *)client{
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Authenticate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler();
    }];
    
    UINavigationController *rootNavigation = (UINavigationController *)self.window.rootViewController;
    UIViewController *top = [rootNavigation visibleViewController];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Superminder" message:@"The application needs to authenticate with Trello" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:action];
    [top presentViewController:alertController animated:YES completion:nil];
    
}

@end
