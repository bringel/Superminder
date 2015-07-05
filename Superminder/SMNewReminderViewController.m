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
    
    self.formDetails = @[@[@{@"label" : @"", @"property" : @"card.name", @"cellIdentifier" : @"SMBasicCell"},
                         @{@"label" : @"", @"property" : @"card.dueDate", @"cellIdentifier" : @"SMBasicCell"}],
                         @[@{@"label" : @"Flexible Reminder", @"property" : @"reminder.flexibleReminder", @"cellIdentifier" : @"SMSwitchCell"},
                         @{@"label" : @"Reminder", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"},
                         @{@"label" : @"Reminder Time", @"property" : @"reminder.reminderDate", @"cellIdentifier" : @"SMDualLabelCell"}],
                         @[@{@"label" : @"Recurring", @"property" : @"reminder.recurring", @"cellIdentifier" : @"SMSwitchCell"}]
                         ];
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
                switchCell.toggleSwitch.on = NO;
                break;
            case 1:
                //reminder date row
                dualCell = (SMDualLabelCell *)cell;
                dualCell.label.text = rowInfo[@"label"];
                dualCell.valueLabel.text = [dateFormatter stringFromDate:self.reminder.reminderDate];
                break;
            case 2:
                //reminder time row
                dualCell = (SMDualLabelCell *)cell;
                dualCell.label.text = rowInfo[@"label"];
                dualCell.valueLabel.text = [timeFormatter stringFromDate:self.reminder.reminderDate];
                break;
            case 3:
            case 4:
                break;
            case 5:
                break;
            case 6:
                break;
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
