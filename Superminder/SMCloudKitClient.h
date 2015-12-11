//
//  SMCloudKitClient.h
//  Superminder
//
//  Created by Bradley Ringel on 7/21/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;
@class SMReminder;

@interface SMCloudKitClient : NSObject

- (void)saveRecord:(CKRecord *)record;
- (void)fetchAllRemindersWithCompletion:(void (^)())completionHandler;
- (SMReminder *)reminderForCardID:(NSString *)cardID;

+ (instancetype)sharedClient;
@end
