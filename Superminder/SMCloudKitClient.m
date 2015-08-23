//
//  SMCloudKitClient.m
//  Superminder
//
//  Created by Bradley Ringel on 7/21/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMCloudKitClient.h"

@implementation SMCloudKitClient


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
@end
