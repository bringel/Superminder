//
//  SMTrelloCard.m
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloCard.h"

@implementation SMTrelloCard

- (instancetype)initWithJSONData:(NSDictionary *)data{
    self = [super init];
    if(self){
        self.cardID = data[@"id"];
        self.name = data[@"name"];
        self.cardDescription = data[@"desc"];
        self.dueDate = data[@"due"];
    }
    return self;
}

@end
