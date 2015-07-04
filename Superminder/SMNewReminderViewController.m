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
@end

@implementation SMNewReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formDetails = @[@{@"label" : @"", @"property" : @"card.name", @"cellIdentifier" : @"SMBasicCell"},
                         @{@"label" : @"", @"property" : @"card.dueDate", @"cellIdentifier" : @"SMBasicCell"},
                         @{@"label" : @"Reminder", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"},
                         @{@"label" : @"Reminder Time", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"},
                         @{@"label" : @"Recurring", @"property" : @"reminder.recurring", @"cellIdentifier" : @"SMSwitchCell"},
                         @{@"label" : @"Every", @"property" : @"reminder.recurringValue", @"cellIdentifier" : @"SMNumberCell"},
                         @{@"label" : @"", @"property" : @"reminder.recurringUnit", @"cellIdentifier" : @"SMSegmentedCell"},
                         @{@"label" : @"Stop Recurring", @"property" : @"reminder.endRecurranceDate", @"cellIdentifier" : @"SMDualLabelCell"}
                         ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2; //start with two, first section has card name and due date, everything else in the second
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0){
        return 2;
    }
    else{
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowInfo;
    if(indexPath.section == 0) {
        rowInfo = self.formDetails[indexPath.row];
    }
    else{
        rowInfo = self.formDetails[indexPath.row + 2];
    }
    NSString *identifier = rowInfo[@"cellIdentifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.dateStyle = NSDateFormatterNoStyle;

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
    else{
        SMDualLabelCell *dualCell;
        SMSwitchCell *switchCell;
        switch(indexPath.row){
            case 0:
                //reminder date row
                dualCell = (SMDualLabelCell *)cell;
                dualCell.label.text = rowInfo[@"label"];
                dualCell.valueLabel.text = [dateFormatter stringFromDate:self.reminder.reminderDate];
                break;
            case 1:
                //reminder time row
                dualCell = (SMDualLabelCell *)cell;
                dualCell.label.text = rowInfo[@"label"];
                dualCell.valueLabel.text = [timeFormatter stringFromDate:self.reminder.reminderDate];
                break;
            case 2:
                //recurring switch row
                switchCell = (SMSwitchCell *)cell;
                switchCell.label.text = rowInfo[@"label"];
                switchCell.toggleSwitch.on = self.reminder.recurring;
                break;
            case 3:
                break;
            case 4:
                break;
            case 5:
                break;
            default:
                break;
        }
    }
    
    return cell;
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
