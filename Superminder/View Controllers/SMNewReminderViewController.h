//
//  SMNewReminderViewController.h
//  Superminder
//
//  Created by Bradley Ringel on 7/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMReminder.h"
#import "SMTrelloCard.h"
#import "BRFormViewController.h"

@interface SMNewReminderViewController : BRFormViewController

@property (strong, nonatomic) SMReminder *reminder;
@property (strong, nonatomic) SMTrelloCard *card;

@end
