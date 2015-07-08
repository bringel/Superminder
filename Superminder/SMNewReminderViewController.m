//
//  SMNewReminderViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMNewReminderViewController.h"
#import "SMDualLabelCell.h"
#import "SMSwitchCell.h"
#import "SMNumberCell.h"
#import "SMSegmentedCell.h"
#import "SMDatePickerCell.h"
#import "SMTimePickerCell.h"

@interface SMNewReminderViewController ()

@property (strong, nonatomic) NSArray *formDetails;
@property (nonatomic) BOOL editingReminderDate;
@property (nonatomic) BOOL editingReminderTime;
@property (nonatomic) BOOL editingEndRecurrenceDate;
@property (nonatomic, getter=isFlexibleRemindersOn) BOOL flexibleRemindersOn;
@property (nonatomic, getter=isRecurringOn) BOOL recurringOn;
@end

@implementation SMNewReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formDetails = @[@[@{@"label" : @"", @"property" : @"card.name", @"cellIdentifier" : @"SMBasicCell"},
                         @{@"label" : @"", @"property" : @"card.dueDate", @"cellIdentifier" : @"SMBasicCell"}],
                         @[@{@"label" : @"Flexible Reminder", @"property" : @"reminder.flexibleReminder", @"cellIdentifier" : @"SMSwitchCell"},
                         @{@"label" : @"Reminder", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"},
                         @{@"label" : @"Reminder Time", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"}],
                         @[@{@"label" : @"Recurring", @"property" : @"reminder.recurring", @"cellIdentifier" : @"SMSwitchCell"}]
                         ];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.formDetails.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.formDetails[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowInfo = self.formDetails[indexPath.section][indexPath.row];
    NSString *identifier = rowInfo[@"cellIdentifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.dateStyle = NSDateFormatterNoStyle;

    SMDualLabelCell *dualCell;
    SMSwitchCell *switchCell;
    SMDatePickerCell *datePickerCell;
    if([identifier isEqualToString:@"SMDualLabelCell"]){
        dualCell = (SMDualLabelCell *)cell;
    }
    else if([identifier isEqualToString:@"SMSwitchCell"]){
        switchCell = (SMSwitchCell *)cell;
    }
    else if([identifier isEqualToString:@"SMDatePickerCell"]){
        datePickerCell = (SMDatePickerCell *)cell;
    }
    if(indexPath.section == 0){
        switch(indexPath.row){
            case 0:
                //card name row
                cell.textLabel.text = self.card.name;
                break;
            case 1:
                //card due date row
                cell.textLabel.text = [dateFormatter stringFromDate:self.card.dueDate];
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 1){
        switch(indexPath.row){
            case 0:
                switchCell.label.text = rowInfo[@"label"];
                switchCell.toggleSwitch.on = self.reminder.flexibleReminder;
                break;
            case 1:
                //reminder date row
                dualCell.label.text = rowInfo[@"label"];
                dualCell.valueLabel.text = [dateFormatter stringFromDate:self.reminder.reminderDate];
                break;
            case 2:
                if(self.editingReminderDate){
                    if(self.reminder.reminderDate != nil){
                        datePickerCell.datePicker.date = self.reminder.reminderDate;
                    }
                    else if(self.card.dueDate != nil){
                        datePickerCell.datePicker.date = self.card.dueDate;
                    }
                    else{
                        datePickerCell.datePicker.date = [NSDate date];
                    }
                }
                else{
                    //reminder time row
                    dualCell.label.text = rowInfo[@"label"];
                    dualCell.valueLabel.text = [timeFormatter stringFromDate:self.reminder.reminderDate];
                }
                break;
            case 3:
                if(self.editingReminderDate){
                    //reminder time row
                    dualCell.label.text = rowInfo[@"label"];
                    dualCell.valueLabel.text = [timeFormatter stringFromDate:self.reminder.reminderDate];
                }
                else if(self.editingReminderTime){
                    if(self.reminder.reminderDate != nil){
                        datePickerCell.datePicker.date = self.reminder.reminderDate;
                    }
                    else if(self.card.dueDate != nil){
                        datePickerCell.datePicker.date = self.card.dueDate;
                    }
                    else{
                        datePickerCell.datePicker.date = [NSDate date];
                    }
                }
            default:
                break;
        }
    }
    else{
        switch(indexPath.row){
            case 0:
                //recurring switch row
                switchCell.label.text = rowInfo[@"label"];
                switchCell.toggleSwitch.on = self.reminder.recurring;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editingReminderDate && indexPath.section == 1 && indexPath.row == 2){
        return 162.0f;
    }
    else if(self.editingReminderTime && indexPath.section == 1 && indexPath.row == 3){
        return 162.0f;
    }
    else{
        return tableView.rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.editingReminderDate && indexPath.section == 1 && indexPath.row == 1){
        self.editingReminderDate = YES;
        NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
        NSMutableArray *mutableSection = [mutableDetails[1] mutableCopy];
        [mutableSection insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDatePickerCell"} atIndex:2];
        mutableDetails[1] = [mutableSection copy];
        self.formDetails = [mutableDetails copy];
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if(!self.editingReminderTime && indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)){
        self.editingReminderTime = YES;
        NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
        NSMutableArray *mutableSection = [mutableDetails[1] mutableCopy];
        [mutableSection insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDatePickerCell"} atIndex:3];
        mutableDetails[1] = [mutableSection copy];
        self.formDetails = [mutableDetails copy];
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
