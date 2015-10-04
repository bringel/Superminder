//
//  SMTrelloBoard.m
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloBoard.h"
#import "SMTrelloList.h"

@interface SMTrelloBoard()

@property (strong, nonatomic) NSMutableDictionary *listIndex;

@end

@implementation SMTrelloBoard

- (instancetype)initWithJSONData:(NSDictionary *)data{
    self = [super init];
    if(self){
        if(data == nil){
            return self;
        }
        
        self.boardID = data[@"id"];
        self.name = data[@"name"];
        self.lists = @[];
        self.listIndex = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addList:(SMTrelloList *)list{
    NSMutableArray *mutableLists = [self.lists mutableCopy];
    [mutableLists addObject:list];
    self.listIndex[list.listID] = @(mutableLists.count -1);
    self.lists = [mutableLists copy];
    list.board = self;
}

- (SMTrelloList *)listWithID:(NSString *)listID{
    NSNumber *listPosition = self.listIndex[listID];
    return self.lists[listPosition.intValue];
}

@end
