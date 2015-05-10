//
//  SMTrelloUser.m
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloUser.h"
#import "SMTrelloBoard.h"

@implementation SMTrelloUser

- (instancetype)initWithJSONData:(NSDictionary *)data{
    self = [super init];
    if(self){
        if(data == nil){
            return self;
        }
        
        self.userID = [data objectForKey:@"id"];
        self.userName = [data objectForKey:@"username"];
        self.fullName = [data objectForKey:@"fullName"];
        self.boards = @[];
    }
    return self;
}

- (void)addBoard:(SMTrelloBoard *)board{
    NSMutableArray *mutableBoards = [self.boards mutableCopy];
    [mutableBoards addObject:board];
    self.boards = [mutableBoards copy];
}

@end
