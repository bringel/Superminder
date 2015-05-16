//
//  SMTrelloBoard.h
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTrelloList;

@interface SMTrelloBoard : NSObject

@property (strong, nonatomic) NSString *boardID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *lists;

- (instancetype)initWithJSONData:(NSDictionary *)data;
- (void)addList:(SMTrelloList *)list;

@end
