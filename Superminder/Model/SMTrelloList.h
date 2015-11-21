//
//  SMTrelloList.h
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTrelloBoard;
@class SMTrelloCard;

@interface SMTrelloList : NSObject

@property (strong, nonatomic) NSString *listID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *cards;
@property (weak, nonatomic) SMTrelloBoard *board;

- (instancetype)initWithJSONData:(NSDictionary *)data;
- (void)addCard:(SMTrelloCard *)card;

@end
