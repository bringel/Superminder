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

- (void)addCard:(SMTrelloCard *)card{
    NSMutableArray *mutableCards = [self.cards mutableCopy];
    [mutableCards addObject:card];
    self.cardsIndex[card.cardID] = @(mutableCards.count - 1);
    self.cards = [mutableCards copy];
}

@end
