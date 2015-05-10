//
//  SMTrelloBoard.m
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloBoard.h"
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

@end
