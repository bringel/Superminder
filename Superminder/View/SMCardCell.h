//
//  SMCardCell.h
//  Superminder
//
//  Created by Bradley Ringel on 10/3/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *boardColorView;
@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *boardBackgroundImageView;

@end
