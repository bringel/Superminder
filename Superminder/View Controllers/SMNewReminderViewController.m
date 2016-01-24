//
//  SMNewReminderViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMNewReminderViewController.h"
#import "BRDualLabelCell.h"
#import "BRSwitchCell.h"
#import "BRNumberCell.h"
#import "BRSegmentedCell.h"
#import "BRDatePickerCell.h"
#import "BRTimePickerCell.h"
#import "SMCloudKitClient.h"
#import "CKRecord+Superminder.h"


@interface SMNewReminderViewController ()

@property (strong, nonatomic) SMReminder *oldReminder;

@property (nonatomic) BOOL editingReminderDate;
@property (nonatomic) BOOL editingReminderTime;
@property (nonatomic) BOOL editingEndRecurrenceDate;
@property (nonatomic, getter=isFlexibleRemindersOn) BOOL flexibleRemindersOn;
@property (nonatomic, getter=isRecurringOn) BOOL recurringOn;
@end

@implementation SMNewReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BRSwitchCellToggleAction flexibleToggleAction = ^void(BOOL on){
        [self removeRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
        [self removeRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        
        if(on){
            [self insertRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withData:@{@"label" : @"", @"property" : @"reminder.flexibleValue", @"cellType" : @(BRFormCellTypeNumber)}];
            [self insertRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withData:@{@"label" : @"", @"property" : @"reminder.flexibleUnit", @"cellType": @(BRFormCellTypeSegmented), @"segments" : @[@"Days", @"Weeks", @"Months"]}];
        }
        else{
            [self insertRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withData:@{@"label" : @"Reminder", @"property" : @"reminder.reminderDate", @"cellType" : @(BRFormCellTypeDate)}];
            [self insertRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withData:@{@"label" : @"Reminder Time", @"property" : @"reminder.reminderDate", @"cellType" : @(BRFormCellTypeTime)}];
        }
        self.flexibleRemindersOn = on;
    };
    
    self.formData = @[@[@{@"label" : @"", @"property" : @"card.name", @"cellType" : @(BRFormCellTypeBasic)},
                         @{@"label" : @"", @"property" : @"card.dueDate", @"cellType" : @(BRFormCellTypeBasic)}],
                      @[@{@"label" : @"Flexible Reminder", @"property" : @"reminder.flexibleReminder", @"cellType" : @(BRFormCellTypeSwitch), @"toggleAction" : flexibleToggleAction},
                         @{@"label" : @"Reminder", @"property" : @"reminder.reminderDate", @"cellType" : @(BRFormCellTypeDate)},
                         @{@"label" : @"Reminder Time", @"property" : @"reminder.reminderDate", @"cellType" : @(BRFormCellTypeTime)}],
                         ];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.oldReminder = [self.reminder copy]; //copy the reminder that was passed in so that we can set it back if the user hits cancel
    
    if(self.reminder == nil){
        //there was no reminder linked to the card yet, create a new one now
        self.reminder = [[SMReminder alloc] init];
        self.reminder.trelloCardID = self.card.cardID;
        self.reminder.reminderDate = [self dateRoundedToNearestFifteenMinutes:[NSDate date]];
    }
    
}

- (NSDate *)dateRoundedToNearestFifteenMinutes:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    NSInteger rounded = components.minute;
    if(components.minute % 15 != 0){
        rounded = ((components.minute / 15) + 1) * 15;
    }
    components.minute = rounded;
    
    return [cal dateFromComponents:components];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)cancelAdding:(id)sender{
    self.reminder = [self.oldReminder copy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNewReminder:(id)sender{
    
    [self.view endEditing:NO];
    
    NSDate *alertDate = self.reminder.reminderDate;
    if(self.flexibleRemindersOn){
        //should we also be setting the time? probably
        
        if(self.reminder.flexibleUnit == SMFlexibleUnitDays){
            alertDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:(-1 * self.reminder.flexibleValue) toDate:alertDate options:0];
        }
        else if(self.reminder.flexibleUnit == SMFlexibleUnitWeeks){
            alertDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:(-7 * self.reminder.flexibleValue) toDate:alertDate options:0];
        }
        else if(self.reminder.flexibleUnit == SMFlexibleUnitMonths){
            alertDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:(-1 * self.reminder.flexibleValue) toDate:alertDate options:0];
        }
    }
    
    UILocalNotification *reminderNotification = [[UILocalNotification alloc] init];
    reminderNotification.alertTitle = @"Reminder due";
    reminderNotification.alertBody = self.card.name;
    reminderNotification.timeZone = [[NSCalendar currentCalendar] timeZone];
    reminderNotification.fireDate = alertDate;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:reminderNotification];
    self.reminder.notificationScheduled = YES;
    
    CKRecord *newReminder = [[CKRecord alloc] initWithReminder:self.reminder];
    SMCloudKitClient *client = [[SMCloudKitClient alloc] init];
    [client saveRecord:newReminder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
