//
//  SMTrelloCard.h
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTrelloList;

@interface SMTrelloCard : NSObject

@property (strong, nonatomic) NSString *cardID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *cardDescription;
@property (strong, nonatomic) NSDate *dueDate;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSArray *labels;
@property (weak, nonatomic) SMTrelloList *list;

- (instancetype)initWithJSONData:(NSDictionary *)data;

@end
