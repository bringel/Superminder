//
//  CKRecord.m
//  Superminder
//
//  Created by Bradley Ringel on 7/21/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "CKRecord+Superminder.h"

@implementation CKRecord (Superminder)

- (instancetype)initWithReminder:(SMReminder *)reminder{
    self = [self initWithRecordType:@"SMReminder"];
    if(self){
        self[@"trelloCardID"] = reminder.trelloCardID;
        self[@"reminderDate"] = reminder.reminderDate;
        self[@"completed"] = [NSNumber numberWithBool:reminder.completed];
        self[@"flexibleReminder"] = [NSNumber numberWithBool:reminder.flexibleReminder];
        self[@"recurring"] = [NSNumber numberWithBool:reminder.recurring];
        self[@"recurringValue"] = [NSNumber numberWithInt:reminder.recurringValue];
        self[@"recurringUnit"] = [NSNumber numberWithUnsignedInteger:reminder.recurringUnit];
        self[@"endRecurranceDate"] = reminder.endRecurranceDate;
    }
    
    return self;
}

@end
