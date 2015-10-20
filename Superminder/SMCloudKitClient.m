//
//  SMCloudKitClient.m
//  Superminder
//
//  Created by Bradley Ringel on 7/21/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMCloudKitClient.h"
#import "SMReminder.h"

@implementation SMCloudKitClient

+ (instancetype)sharedClient{
    static SMCloudKitClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[SMCloudKitClient alloc] init];
    });
    return client;
}

- (NSDictionary *)remindersCardIDIndex{
    if(_remindersCardIDIndex == nil){
        _remindersCardIDIndex = [[NSDictionary alloc] init];
    }
    return _remindersCardIDIndex;
}

- (void)saveRecord:(CKRecord *)record{
    CKDatabase *database = [[CKContainer defaultContainer] privateCloudDatabase];
    
    [database saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if(error){
            NSLog(@"Error saving record: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Saved record: %@", record);
        }
    }];
}

- (void)fetchAllReminders{
    NSMutableDictionary *mutableIndex = [self.remindersCardIDIndex mutableCopy];
    
    CKDatabase *database = [[CKContainer defaultContainer] privateCloudDatabase];
    NSPredicate *completedPred = [NSPredicate predicateWithFormat:@"%K == 0",@"completed"];
    CKQuery *allRecords = [[CKQuery alloc] initWithRecordType:@"SMReminder" predicate:completedPred];
    [database performQuery:allRecords inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error fetching records %@", error.localizedDescription);
        }
        else{
            for(CKRecord *reminderRec in results){
                SMReminder *reminder = [[SMReminder alloc] initWithRecord:reminderRec];
                [mutableIndex setObject:reminder forKey:reminder.trelloCardID];
            }
            self.remindersCardIDIndex = [mutableIndex copy];
        }
    }];
}
@end
