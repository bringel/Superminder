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

@property (strong, nonatomic) NSIndexPath *currentlyEditingIndex; //The index path for the row that is being edited with a date picker or time picker, not the indexpath of the picker itself.

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
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
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

- (BOOL)saveData{
    return YES;
}

- (BOOL)cancelSave{
    return YES;
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
    BRDatePickerCell *datePickerCell;
    BRTimePickerCell *timePickerCell;
    
    NSDictionary *rowData = [self rowDataForIndexPath:indexPath];
    
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
            [numberCell.numberField addTarget:self action:@selector(numberValueChanged:) forControlEvents:UIControlEventValueChanged];
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
            [segmentedCell.options addTarget:self action:@selector(segmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell = segmentedCell;
            break;
        case BRFormCellTypeSwitch:
            switchCell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier forIndexPath:indexPath];
            switchCell.toggleSwitch.on = [propertyVal boolValue]; //property val will be an nsnumber in this case
            switchCell.label.text = labelText;
            [switchCell.toggleSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell = switchCell;
            break;
        case BRFormCellTypeDate:
            if(indexPath == [NSIndexPath indexPathForRow:self.currentlyEditingIndex.row+1 inSection:self.currentlyEditingIndex.section]){
                datePickerCell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier forIndexPath:indexPath];
                if([propertyVal isKindOfClass:[NSDate class]]){
                    NSDate *date = (NSDate *)propertyVal;
                    if(date == nil){
                        date = [NSDate date];
                    }
                    datePickerCell.datePicker.date = date;
                    [datePickerCell.datePicker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];
                }
                cell = datePickerCell;
            }
            else{
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
            }
            break;
        case BRFormCellTypeTime:
            if(indexPath == [NSIndexPath indexPathForRow:self.currentlyEditingIndex.row+1 inSection:self.currentlyEditingIndex.section]){
                timePickerCell = [tableView dequeueReusableCellWithIdentifier:timeCellIdentifier forIndexPath:indexPath];
                if([propertyVal isKindOfClass:[NSDate class]]){
                    NSDate *date = (NSDate *)propertyVal;
                    if(date == nil){
                        date = [NSDate date];
                    }
                    timePickerCell.timePicker.date = date;
                    [timePickerCell.timePicker addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventValueChanged];
                }
                cell = timePickerCell;
            }
            else{
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
            }
            break;
        default:
            break;
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *rowData = [self rowDataForIndexPath:indexPath];
    BRFormCellType cellType = [rowData[@"cellType"] integerValue];
    NSDictionary *newRowData = [[NSDictionary alloc] initWithDictionary:rowData copyItems:YES];
    NSIndexPath *pickerIndex;
    
    //need to remove something if there is a picker and it is in this section
    BOOL hasPickerToRemove = (self.currentlyEditingIndex != nil && self.currentlyEditingIndex.section == indexPath.section);
    //only add a picker if the user tapped on a row that is not the currently editing row
    BOOL needToInsertPicker = (self.currentlyEditingIndex != indexPath);
    
    if(cellType == BRFormCellTypeDate || cellType == BRFormCellTypeTime){
        //edit formData to remove the current picker if there is one
        NSMutableArray *mutableSection = [[self sectionDataForIndexPath:indexPath] mutableCopy];
        if(hasPickerToRemove){
            [mutableSection removeObjectAtIndex:self.currentlyEditingIndex.row+1];
            if(indexPath.row > self.currentlyEditingIndex.row){ //if the selected row was below the picker, we need to decrement the indexpath by one
                indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            }
        }
        else if(needToInsertPicker){
            //insert row for new picker view
            pickerIndex = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            [mutableSection insertObject:newRowData atIndex:pickerIndex.row];
        }
        
        [self setSectionData:[mutableSection copy] forIndexPath:indexPath];
        
        //edit the tableview
        [tableView beginUpdates];
        if(hasPickerToRemove){
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentlyEditingIndex.row+1 inSection:self.currentlyEditingIndex.section]] withRowAnimation:UITableViewRowAnimationFade];
            self.currentlyEditingIndex = nil;
        }
        else if(needToInsertPicker){
            self.currentlyEditingIndex = indexPath;
            [tableView insertRowsAtIndexPaths:@[pickerIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView endUpdates];
    }
}

#pragma mark - Value Changed Handling

- (void)dateValueChanged:(UIDatePicker *)picker{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:picker.date];
    NSDictionary *rowData = [self rowDataForIndexPath:self.currentlyEditingIndex];
    NSDate *oldDate = [self valueForKeyPath:rowData[@"property"]];
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour) fromDate:oldDate];
    //sync up the time from the old date with the new date
    components.second = timeComponents.second;
    components.minute = timeComponents.minute;
    components.hour = timeComponents.hour;
    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [self setValue:newDate forKeyPath:rowData[@"property"]];
    
    [self.tableView reloadRowsAtIndexPaths:@[self.currentlyEditingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)timeValueChanged:(UIDatePicker *)picker{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour) fromDate:picker.date];
    NSDictionary *rowData = [self rowDataForIndexPath:self.currentlyEditingIndex];
    NSDate *oldTime = [self valueForKeyPath:rowData[@"property"]];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:oldTime];
    //sync up the date from the old date with the new date
    components.day = dateComponents.day;
    components.month = dateComponents.month;
    components.year = dateComponents.year;
    NSDate *newTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [self setValue:newTime forKeyPath:rowData[@"property"]];
    
    [self.tableView reloadRowsAtIndexPaths:@[self.currentlyEditingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)numberValueChanged:(UITextField *)textField{
    NSIndexPath *cellPath = [self cellIndexPathForView:textField];
    NSDictionary *rowData = [self rowDataForIndexPath:cellPath];
    NSNumber *val = @(textField.text.intValue);
    [self setValue:val forKey:rowData[@"property"]];
}

- (void)switchValueChanged:(UISwitch *)toggle{
    NSIndexPath *cellPath = [self cellIndexPathForView:toggle];
    NSDictionary *rowData = [self rowDataForIndexPath:cellPath];
    [self setValue:@(toggle.on) forKeyPath:rowData[@"property"]];
    BRSwitchCellToggleAction toggleAction = rowData[@"toggleAction"];
    toggleAction(toggle.on);
}

- (void)segmentedValueChanged:(UISegmentedControl *)segments{
    NSIndexPath *cellPath = [self cellIndexPathForView:segments];
    NSDictionary *rowData = [self rowDataForIndexPath:cellPath];
    NSNumber *val = @(segments.selectedSegmentIndex);
    [self setValue:val forKey:rowData[@"property"]];
}
#pragma mark - Helpers

- (NSDictionary *)rowDataForIndexPath:(NSIndexPath *)indexPath{
    if([self.formData[indexPath.section] isKindOfClass:[NSDictionary class]]){
        return self.formData[indexPath.row];
    }
    else{
        return self.formData[indexPath.section][indexPath.row];
    }
}

- (NSArray *)sectionDataForIndexPath:(NSIndexPath *)indexPath{
    if([self.formData[indexPath.section] isKindOfClass:[NSDictionary class]]){
        return self.formData;
    }
    else{
        return self.formData[indexPath.section];
    }
}

- (void)setSectionData:(NSArray *)data forIndexPath:(NSIndexPath *)indexPath{
    if([self.formData[indexPath.section] isKindOfClass:[NSDictionary class]]){
        self.formData = [[NSArray alloc] initWithArray:data copyItems:YES];
    }
    else{
        NSMutableArray *mutableFormData = [self.formData mutableCopy];
        mutableFormData[indexPath.section] = data;
        self.formData = [mutableFormData copy];
    }
}

- (NSIndexPath *)cellIndexPathForView:(UIView *)view{
    if([view isKindOfClass:[UITableViewCell class]]){
        return [self.tableView indexPathForCell:(UITableViewCell *)view];
    }
    else if(view.superview == nil){
        return [self.tableView indexPathForCell:(UITableViewCell *)view];
    }
    else{
        return [self cellIndexPathForView:view.superview];
    }
}

#pragma mark - Row Operations

- (void)insertRowAtIndexPath:(NSIndexPath *)index withData:(NSDictionary *)rowData{
    NSMutableArray *mutableSection = [[self sectionDataForIndexPath:index] mutableCopy];
    [mutableSection insertObject:rowData atIndex:index.row];
    
    [self setSectionData:[mutableSection copy] forIndexPath:index];
    
    [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeRowAtIndexPath:(NSIndexPath *)index{
    NSMutableArray *mutableSection = [[self sectionDataForIndexPath:index] mutableCopy];
    [mutableSection removeObjectAtIndex:index.row];
    
    [self setSectionData:[mutableSection copy] forIndexPath:index];
    
    [self.tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
