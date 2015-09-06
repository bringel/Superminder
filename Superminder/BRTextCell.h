//
//  BRTextCell.h
//  Superminder
//
//  Created by Bradley Ringel on 9/6/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
