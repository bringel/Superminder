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
        self.reminder.reminderDate = [NSDate date];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)expandDatePickerInTableView:(UITableView *)tableView {
    if(self.editingReminderDate){
        return;
    }
    self.editingReminderDate = YES;
    NSMutableArray *mutableDetails = [self.formData mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formData[1] mutableCopy];
    [mutableSectionDetails insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDatePickerCell"} atIndex:2];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formData = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (void)collapseDatePickerInTableView:(UITableView *)tableView{
    if(!self.editingReminderDate){
        return;
    }
    self.editingReminderDate = NO;
    NSMutableArray *mutableDetails = [self.formData mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formData[1] mutableCopy];
    [mutableSectionDetails removeObjectAtIndex:2];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formData = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

- (void)expandTimePickerInTableView:(UITableView *)tableView {
    if(self.editingReminderTime){
        return;
    }
    self.editingReminderTime = YES;
    NSMutableArray *mutableDetails = [self.formData mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formData[1] mutableCopy];
    [mutableSectionDetails insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMTimePickerCell"} atIndex:3];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formData = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (void)collapseTimePickerInTableView:(UITableView *)tableView{
    if(!self.editingReminderTime){
        return;
    }
    self.editingReminderTime = NO;
    NSMutableArray *mutableDetails = [self.formData mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formData[1] mutableCopy];
    [mutableSectionDetails removeObjectAtIndex:3];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formData = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    
//    if(self.flexibleRemindersOn){
//        return; //don't need to do anything if users are doing flexible reminders
//    }
//    
//    if(indexPath.section == 1 && indexPath.row == 1){
//        if(!self.editingReminderDate){
//            [self collapseTimePickerInTableView:tableView];
//            [self expandDatePickerInTableView:tableView];
//        }
//        else{
//            [self collapseDatePickerInTableView:tableView];
//        }
//    }
//    else if(indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)){
//        //It seems like the date/time pickers are handling any taps, so if the date picker is open, we can't get selections at index 2, which is why it's okay to run this code for either 2 or 3
//        if(!self.editingReminderTime){
//            [self collapseDatePickerInTableView:tableView];
//            [self expandTimePickerInTableView:tableView];
//        }
//        else{
//            [self collapseTimePickerInTableView:tableView];
//        }
//    }
//}

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
    
    self.card.linkedReminder = self.oldReminder;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNewReminder:(id)sender{
    
    [self.view endEditing:NO];
    
    CKRecord *newReminder = [[CKRecord alloc] initWithReminder:self.reminder];
    SMCloudKitClient *client = [[SMCloudKitClient alloc] init];
    [client saveRecord:newReminder];
    self.card.linkedReminder = self.reminder;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
