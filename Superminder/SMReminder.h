//
//  SMReminder.h
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SMRecurringUnit) {
    SMRecurringUnitDays,
    SMRecurringUnitMonths,
    SMRecurringUnitYears
};

@interface SMReminder : NSObject

@property (strong, nonatomic) NSString *cloudKitID;
@property (strong, nonatomic) NSString *trelloCardID;
@property (strong, nonatomic) NSDate *reminderDate;
@property (nonatomic, getter=isCompleted) BOOL completed;
@property (nonatomic, getter=isRecurring) BOOL recurring;
@property (nonatomic) int recurringValue;
@property (nonatomic) SMRecurringUnit recurringUnit;
@property (strong, nonatomic) NSDate *endRecurranceDate;

@end
