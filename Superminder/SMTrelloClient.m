//
//  SMTrelloClient.m
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//
@import Foundation;
#import "SMTrelloClient.h"
#import "Lockbox.h"
#import "NSURLRequest+SMRequestBuilding.h"
#import "SMTrelloBoard.h"
#import "SMTrelloList.h"
#import "SMTrelloCard.h"

@interface SMTrelloClient ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURL *trelloBaseURL;
@property (strong, nonatomic) NSString *userToken;

@property (strong, nonatomic) NSMutableArray *currentDataTasks;

@end

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
        
        self.trelloBaseURL = [NSURL URLWithString:@"https://api.trello.com/1/"];
        
        self.userToken = [Lockbox stringForKey:kTrelloUserKey];
        
        NSURLRequest *urlRequest = [NSURLRequest buildRequestForPath:@"members/me" withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken} relativeToURL:self.trelloBaseURL usingMethod:@"HEAD"];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          if(httpResponse.statusCode == 401){
                                              self.needsReauthentication = YES;
                                              [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedsReauthentication object:self]];
                                          }
                                      }];
 
        [task resume];
    }
    return self;
}

- (NSURLSession *)session{
    if(_session == nil){
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadRevalidatingCacheData;
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return _session;
}

- (NSMutableArray *)currentDataTasks{
    if(_currentDataTasks == nil){
        _currentDataTasks = [[NSMutableArray alloc] init];
    }
    return _currentDataTasks;
}

- (void)getCurrentUserInfo{
    
    NSURLRequest *urlRequest = [NSURLRequest buildRequestForPath:@"members/me" withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken} relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                      if(httpResponse.statusCode == 200){
                                          NSError *error;
                                          NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                          
                                          self.currentUser = [[SMTrelloUser alloc] initWithJSONData:responseData];
                                      }
                                  }];

    [task resume];
}

- (void)getAlBoardDataForUser:(SMTrelloUser *)user{
    
    NSURLRequest *idRequest = [NSURLRequest buildRequestForPath:@"members/me" withParameters:@{ @"fields" : @"idBoards", @"key" : self.apiKey, @"token" : self.userToken } relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
    NSURLSessionDataTask *idTask = [self.session dataTaskWithRequest:idRequest completionHandler:
                                    ^(NSData *data, NSURLResponse *response, NSError *error) {
                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                        if(httpResponse.statusCode == 200){
                                            NSError *error;
                                            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                            if(responseData[@"idBoards"] != nil){
                                                [self getDataForBoardIDs:responseData[@"idBoards"]];
                                            }
                                        }
                                    }];
    [idTask resume];
}

- (void)getDataForBoardIDs:(NSArray *)boardIDs{
    if(boardIDs == nil || boardIDs.count == 0){
        return;
    }
    for (NSString *boardID in boardIDs) {
        [self getDataForBoard:boardID];
    }
}

- (void)getDataForBoard:(NSString *)boardID{

    NSString *requestPath = [NSString stringWithFormat:@"boards/%@", boardID];
    NSURLRequest *boardRequest = [NSURLRequest buildRequestForPath:requestPath withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken, @"lists" : @"all", @"cards" : @"all" } relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
    NSURLSessionDataTask *boardTask = [self.session dataTaskWithRequest:boardRequest completionHandler:
                                       ^(NSData *data, NSURLResponse *response, NSError *error) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                           if(httpResponse.statusCode == 200){
                                               NSError *error;
                                               NSDictionary *boardData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                               SMTrelloBoard *newBoard = [[SMTrelloBoard alloc] initWithJSONData:boardData];
                                               [self.currentUser addBoard:newBoard];
                                               for(NSDictionary *listData in boardData[@"lists"]){
                                                   SMTrelloList *newList = [[SMTrelloList alloc] initWithJSONData:listData];
                                                   [newBoard addList:newList];
                                               }
                                           }
                                       }];
    
    boardTask.taskDescription = [NSString stringWithFormat:@"Fetch board - %@", boardID];
    [self.currentDataTasks addObject:boardTask];
    [boardTask resume];
}

@end
