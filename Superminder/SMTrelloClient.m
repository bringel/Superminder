//
//  SMTrelloClient.m
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMTrelloClient.h"

@implementation SMTrelloClient


+ (instancetype)sharedClient{
    static SMTrelloClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[SMTrelloClient alloc] init];
    });
    return client;
}

- (instancetype)init{
    self = [super init];
    if(self != nil){
        NSString *configPath = [[NSBundle mainBundle] pathForResource:@"Superminder-config" ofType:@"plist"];
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
        self.apiKey = config[@"trello-api-key"];
    }
    return self;
}
@end
