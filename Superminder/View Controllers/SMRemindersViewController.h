//
//  SMRemindersViewController.h
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTrelloClient.h"

@interface SMRemindersViewController : UITableViewController <SMTrelloClientDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end
