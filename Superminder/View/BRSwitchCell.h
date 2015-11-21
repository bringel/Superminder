//
//  BRSwitchCell.h
//  Superminder
//
//  Created by Bradley Ringel on 7/4/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end
