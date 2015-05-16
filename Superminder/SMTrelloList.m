//
//  SMTrelloList.m
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloList.h"
#import "SMTrelloCard.h"

@interface SMTrelloList ()

@property (strong, nonatomic) NSMutableDictionary *cardsIndex;

@end

@implementation SMTrelloList

- (instancetype)initWithJSONData:(NSDictionary *)data{
    self = [super init];
    if(self){
        if(data != nil){
            self.listID = data[@"id"];
            self.name = data[@"name"];
            self.cards = @[];
            self.cardsIndex = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

@end
