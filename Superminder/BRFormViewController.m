//
//  BRFormViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 9/6/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import "BRFormViewController.h"
#import "BRDatePickerCell.h"
#import "BRTimePickerCell.h"
#import "BRDualLabelCell.h"
#import "BRNumberCell.h"
#import "BRSwitchCell.h"
#import "BRSegmentedCell.h"
#import "BRTextCell.h"

static NSString * const basicCellIdentifier = @"BRBasicCell";
static NSString * const textCellIdentifier = @"BRTextCell";
static NSString * const dualLabelCellIdentifier = @"BRDualLabelCell";
static NSString * const numberCellIdentifier = @"BRNumberCell";
static NSString * const segmentedCellIdentifier = @"BRSegmentedCell";
static NSString * const switchCellIdentifier = @"BRSwitchCell";
static NSString * const dateCellIdentifier = @"BRDatePickerCell";
static NSString * const timeCellIdentifier = @"BRTimePickerCell";

@interface BRFormViewController ()

@property (strong, nonatomic) NSMutableArray *datePickerRows; //store rows that should expand a date picker cell when selected. Objects should be NSIndexPaths
@property (strong, nonatomic) NSMutableArray *timePickerRows; //store rows that should expand a time picker cell when selected. Objects should be NSIndexPaths
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@end

@implementation BRFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRBasicCell" bundle:mainBundle] forCellReuseIdentifier:basicCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRBasicCell" bundle:mainBundle] forCellReuseIdentifier:basicCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRTextCell" bundle:mainBundle] forCellReuseIdentifier:textCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRDualLabelCell" bundle:mainBundle] forCellReuseIdentifier:dualLabelCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRNumberCell" bundle:mainBundle] forCellReuseIdentifier:numberCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRSegmentedCell" bundle:mainBundle] forCellReuseIdentifier:segmentedCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRSwitchCell" bundle:mainBundle] forCellReuseIdentifier:switchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRDatePickerCell" bundle:mainBundle] forCellReuseIdentifier:dateCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRTimePickerCell" bundle:mainBundle] forCellReuseIdentifier:timeCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)formData{
    if(_formData == nil){
        _formData = [[NSArray alloc] init];
    }
    return _formData;
}

- (NSDateFormatter *)dateFormatter{
    if(_dateFormatter == nil){
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return _dateFormatter;
}

- (NSDateFormatter *)timeFormatter{
    if(_timeFormatter == nil){
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateStyle = NSDateFormatterNoStyle;
        _timeFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _timeFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.formData.firstObject isKindOfClass:[NSArray class]]){
        return self.formData.count;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionData = self.formData[section];
    if([sectionData isKindOfClass:[NSArray class]]){
        return ((NSArray *)sectionData).count;
    }
    else{
        return self.formData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BRDualLabelCell *dualLabelCell;
    BRNumberCell *numberCell;
    BRSwitchCell *switchCell;
    BRSegmentedCell *segmentedCell;
    BRTextCell *textCell;
    
    NSDictionary *rowData;
    if([self.formData[indexPath.section] isKindOfClass:[NSDictionary class]]){
        rowData = self.formData[indexPath.row];
    }
    else{
        rowData = self.formData[indexPath.section][indexPath.row];
    }
    
    BRFormCellType type = [[rowData objectForKey:@"cellType"] integerValue];
    id propertyVal = [self valueForKeyPath:rowData[@"property"]];
    NSString *labelText = rowData[@"label"];
    NSArray *segments;
    switch(type){
        case BRFormCellTypeBasic:
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            if([propertyVal isKindOfClass:[NSString class]]){
                cell.textLabel.text = (NSString *)propertyVal;
            }
            else if ([propertyVal isKindOfClass:[NSDate class]]){
                cell.textLabel.text = [self.dateFormatter stringFromDate:propertyVal];
            }
            break;
        case BRFormCellTypeText:
            textCell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
            cell = textCell;
            break;
        case BRFormCellTypeDualLabel:
            dualLabelCell = [tableView dequeueReusableCellWithIdentifier:dualLabelCellIdentifier forIndexPath:indexPath];
            if([propertyVal isKindOfClass:[NSString class]]){
                dualLabelCell.valueLabel.text = (NSString *)propertyVal;
                dualLabelCell.label.text = labelText;
             }
            cell = dualLabelCell;
            break;
        case BRFormCellTypeNumber:
            numberCell = [tableView dequeueReusableCellWithIdentifier:numberCellIdentifier forIndexPath:indexPath];
            if([propertyVal isKindOfClass:[NSNumber class]]){
                numberCell.numberField.text = [NSString stringWithFormat:@"%d",((NSNumber *)propertyVal).intValue]; //maybe want to use NSNumberFormatter at some point
            }
            numberCell.label.text = labelText;
            cell = numberCell;
            break;
        case BRFormCellTypeSegmented:
            segmentedCell = [tableView dequeueReusableCellWithIdentifier:segmentedCellIdentifier forIndexPath:indexPath];
            segments = rowData[@"segments"];
            [segmentedCell.options removeAllSegments];
            for(int i = 0; i < segments.count; i++){
                [segmentedCell.options insertSegmentWithTitle:segments[i] atIndex:i animated:NO];
            }
            if((NSInteger)propertyVal < segments.count){
                segmentedCell.options.selectedSegmentIndex = (NSInteger)propertyVal;
            }
            cell = segmentedCell;
            break;
        case BRFormCellTypeSwitch:
            switchCell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier forIndexPath:indexPath];
            switchCell.toggleSwitch.on = (BOOL)propertyVal;
            switchCell.label.text = labelText;
            cell = switchCell;
            break;
        case BRFormCellTypeDate:
            dualLabelCell = [tableView dequeueReusableCellWithIdentifier:dualLabelCellIdentifier forIndexPath:indexPath]; //use a dual label cell since the date picker is not shown until the user taps on the row
            if([propertyVal isKindOfClass:[NSDate class]]){
                NSDate *date = (NSDate *)propertyVal;
                if(date == nil){
                    date = [NSDate date];
                }
                dualLabelCell.valueLabel.text = [self.dateFormatter stringFromDate:date];
                dualLabelCell.label.text = labelText;
            }
            cell = dualLabelCell;
            break;
        case BRFormCellTypeTime:
            dualLabelCell = [tableView dequeueReusableCellWithIdentifier:dualLabelCellIdentifier forIndexPath:indexPath]; //use a dual label cell since the time picker is not shown until the user taps on the row
            if([propertyVal isKindOfClass:[NSDate class]]){
                NSDate *time = (NSDate *)propertyVal;
                if(time == nil){
                    time = [NSDate date];
                }
                dualLabelCell.valueLabel.text = [self.timeFormatter stringFromDate:time];
                dualLabelCell.label.text = labelText;
            }
            cell = dualLabelCell;
            break;
        default:
            break;
        
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
