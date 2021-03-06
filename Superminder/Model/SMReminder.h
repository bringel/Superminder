//
//  SMReminder.h
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;

typedef NS_ENUM(NSUInteger, SMRecurringUnit) {
    SMRecurringUnitDays,
    SMRecurringUnitMonths,
    SMRecurringUnitYears
};

typedef NS_ENUM(NSUInteger, SMFlexibleUnit) {
    SMFlexibleUnitDays,
    SMFlexibleUnitWeeks,
    SMFlexibleUnitMonths
};
@interface SMReminder : NSObject <NSCopying>

@property (strong, nonatomic) CKRecordID *cloudKitID;
@property (strong, nonatomic) NSString *trelloCardID;
@property (strong, nonatomic) NSDate *reminderDate;
@property (nonatomic, getter=isCompleted) BOOL completed;
@property (nonatomic, getter=isFlexibleReminder) BOOL flexibleReminder;
@property (nonatomic) int flexibleValue;
@property (nonatomic) SMFlexibleUnit flexibleUnit;
@property (nonatomic, getter=isRecurring) BOOL recurring;
@property (nonatomic) int recurringValue;
@property (nonatomic) SMRecurringUnit recurringUnit;
@property (strong, nonatomic) NSDate *endRecurranceDate;
@property (nonatomic) BOOL notificationScheduled;

+ (instancetype)reminderWithRecord:(CKRecord *)rec;

- (instancetype)initWithRecord:(CKRecord *)rec;
@end
