//
//  BRFormViewController.h
//  Superminder
//
//  Created by Bradley Ringel on 9/6/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BRFormCellType) {
    BRFormCellTypeBasic,
    BRFormCellTypeText,
    BRFormCellTypeDualLabel,
    BRFormCellTypeNumber,
    BRFormCellTypeSegmented,
    BRFormCellTypeSwitch,
    BRFormCellTypeDate,
    BRFormCellTypeTime,
};

@interface BRFormViewController : UITableViewController

@property (nonatomic, strong) NSArray *formData;

- (BOOL)saveData;
- (BOOL)cancelSave;

- (void)insertRowAtIndexPath:(NSIndexPath *)index withData:(NSDictionary *)rowData;
- (void)removeRowAtIndexPath:(NSIndexPath *)index;
@end
