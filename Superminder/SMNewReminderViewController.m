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

@property (strong, nonatomic) SMReminder *oldReminder;

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
        return 44.0f;
    }
}

- (void)expandDatePickerInTableView:(UITableView *)tableView {
    if(self.editingReminderDate){
        return;
    }
    self.editingReminderDate = YES;
    NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formDetails[1] mutableCopy];
    [mutableSectionDetails insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDatePickerCell"} atIndex:2];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formDetails = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (void)collapseDatePickerInTableView:(UITableView *)tableView{
    if(!self.editingReminderDate){
        return;
    }
    self.editingReminderDate = NO;
    NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formDetails[1] mutableCopy];
    [mutableSectionDetails removeObjectAtIndex:2];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formDetails = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

- (void)expandTimePickerInTableView:(UITableView *)tableView {
    if(self.editingReminderTime){
        return;
    }
    self.editingReminderTime = YES;
    NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formDetails[1] mutableCopy];
    [mutableSectionDetails insertObject:@{@"label" : @"", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMTimePickerCell"} atIndex:3];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formDetails = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (void)collapseTimePickerInTableView:(UITableView *)tableView{
    if(!self.editingReminderTime){
        return;
    }
    self.editingReminderTime = NO;
    NSMutableArray *mutableDetails = [self.formDetails mutableCopy];
    NSMutableArray *mutableSectionDetails = [self.formDetails[1] mutableCopy];
    [mutableSectionDetails removeObjectAtIndex:3];
    mutableDetails[1] = [mutableSectionDetails copy];
    self.formDetails = [mutableDetails copy];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == 1 && indexPath.row == 1){
        if(!self.editingReminderDate){
            [self collapseTimePickerInTableView:tableView];
            [self expandDatePickerInTableView:tableView];
        }
        else{
            [self collapseDatePickerInTableView:tableView];
        }
    }
    else if(indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)){
        //It seems like the date/time pickers are handling any taps, so if the date picker is open, we can't get selections at index 2, which is why it's okay to run this code for either 2 or 3
        if(!self.editingReminderTime){
            [self collapseDatePickerInTableView:tableView];
            [self expandTimePickerInTableView:tableView];
        }
        else{
            [self collapseTimePickerInTableView:tableView];
        }
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
    //TODO:Save the reminder to cloudkit!!
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Value Changed handling

- (IBAction)datePickerValueChanged:(id)sender {
    if(self.editingReminderDate){
        UIDatePicker *picker = (UIDatePicker *)sender;
        if(self.reminder.reminderDate == nil){
            self.reminder.reminderDate = picker.date;
            return;
        }
        NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.reminder.reminderDate];
        NSDateComponents *pickerComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:picker.date];
        currentComponents.year = pickerComponents.year;
        currentComponents.month = pickerComponents.month;
        currentComponents.day = pickerComponents.day;
        self.reminder.reminderDate = [[NSCalendar currentCalendar] dateFromComponents:currentComponents]; //this should update the date but not wipe out the time
    }
}

- (IBAction)timePickerValueChanged:(id)sender {
    if(self.editingReminderTime){
        UIDatePicker *picker = (UIDatePicker *)sender;
        if(self.reminder.reminderDate == nil){
            self.reminder.reminderDate = picker.date;
            return;
        }
        NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.reminder.reminderDate];
        NSDateComponents *pickerComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:picker.date];
        currentComponents.hour = pickerComponents.hour;
        currentComponents.minute = pickerComponents.minute;
        self.reminder.reminderDate = [[NSCalendar currentCalendar] dateFromComponents:currentComponents]; //this should update the time but not wipe out the date
    }
}

- (IBAction)switchValueChanged:(id)sender {
}

- (IBAction)segmentedValueChanged:(id)sender {
}
@end
