//
//  SMCardCollectionViewCell.h
//  Superminder
//
//  Created by Bradley Ringel on 5/15/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
