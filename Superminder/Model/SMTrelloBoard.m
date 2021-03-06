//
//  SMTrelloBoard.m
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloBoard.h"
#import "SMTrelloList.h"
@import UIKit;

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
        NSDictionary *prefs = data[@"prefs"];
        self.backgroundColor = [UIColor colorWithHexadecimalColor:prefs[@"backgroundColor"]];
        if(prefs[@"backgroundImage"] != [NSNull null]){
            self.backgroundImageURL = [NSURL URLWithString:prefs[@"backgroundImage"]];
        }
        self.labels = data[@"labelNames"];
        self.boardDescription = data[@"desc"];
    }
    
    return self;
}

+ (NSCache *)boardBackgroundsCache{
    static NSCache *backgroundsCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundsCache = [[NSCache alloc] init];
        backgroundsCache.name = @"Board Backgrounds Cache";
    });
    return backgroundsCache;
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
