//
//  SMRemindersViewDataSource.h
//  Superminder
//
//  Created by Bradley Ringel on 2/16/16.
//  Copyright © 2016 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMReminder.h"
#import "SMTrelloCard.h"
@import UIKit;

@interface SMRemindersViewDataSource : NSObject

- (SMReminder *)reminderForIndexPath:(NSIndexPath *)indexPath;
- (SMTrelloCard *)cardForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cardTitleForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)listNameForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)reminderDueTextForIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)backgroundImageForIndexPath:(NSIndexPath *)indexPath;

@end
