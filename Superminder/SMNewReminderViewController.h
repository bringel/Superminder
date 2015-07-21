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

@interface SMNewReminderViewController : UITableViewController

@property (strong, nonatomic) SMReminder *reminder;
@property (strong, nonatomic) SMTrelloCard *card;

- (IBAction)datePickerValueChanged:(id)sender;
- (IBAction)timePickerValueChanged:(id)sender;
- (IBAction)switchValueChanged:(id)sender;
- (IBAction)segmentedValueChanged:(id)sender;

- (IBAction)cancelAdding:(id)sender;
- (IBAction)saveNewReminder:(id)sender;

@end
