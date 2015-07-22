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
    SMReminder *copy = [super copy];
    
    copy.cloudKitID = [self.cloudKitID copy];
    copy.trelloCardID = [self.trelloCardID copy];
    copy.reminderDate = [self.reminderDate copy];
    copy.completed = self.completed;
    copy.flexibleReminder = self.flexibleReminder;
    copy.recurring = self.recurring;
    copy.recurringValue = self.recurringValue;
    copy.recurringUnit = self.recurringUnit;
    copy.endRecurranceDate = [self.endRecurranceDate copy];
    
    return copy;
}
@end
