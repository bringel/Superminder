//
//  SMReminder.m
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMReminder.h"

@implementation SMReminder

- (id)copyWithZone:(NSZone *)zone{
    SMReminder *copy = [[SMReminder allocWithZone:zone] init];
    
    copy.cloudKitID = [self.cloudKitID copy];
    copy.trelloCardID = [self.trelloCardID copy];
    copy.reminderDate = [self.reminderDate copy];
    copy.completed = self.completed;
    copy.flexibleReminder = self.flexibleReminder;
    copy.recurring = self.recurring;
    copy.recurringValue = self.recurringValue;
    copy.recurringUnit = self.recurringUnit;
    copy.endRecurranceDate = [self.endRecurranceDate copy];
    copy.notificationScheduled = self.notificationScheduled;
    
    return copy;
}

+ (instancetype)reminderWithRecord:(id)rec{
    return [[SMReminder alloc] initWithRecord:rec];
}

- (instancetype)initWithRecord:(id)rec{
    self = [super init];
    if(self){
//        self.version = rec[@"version"];
        self.cloudKitID = rec[@"recordID"];
        self.trelloCardID = rec[@"trelloCardID"];
        self.reminderDate = rec[@"reminderDate"];
        self.completed = [rec[@"completed"] boolValue];
        self.flexibleReminder = [rec[@"flexibleReminder"] boolValue];
        self.recurring = [rec[@"flexibleReminder"] boolValue];
        self.recurringValue =[rec[@"reucrringValue"] intValue];
        self.recurringUnit = [rec[@"recurringUnit"] unsignedIntegerValue];
        self.endRecurranceDate = rec[@"endRecurranceDate"];
        self.notificationScheduled = [rec[@"notificationScheduled"] boolValue];
    }
    return self;
}
@end
