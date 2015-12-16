//
//  SMTrelloClient.m
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//
@import Foundation;
@import SafariServices;
#import "AppDelegate.h"
#import "SMTrelloClient.h"
#import "Lockbox.h"
#import "NSURLRequest+SMRequestBuilding.h"
#import "SMTrelloBoard.h"
#import "SMTrelloList.h"
#import "SMTrelloCard.h"

NSString * const kTrelloUserKey  = @"trello-user-key";

@interface SMTrelloClient ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURL *trelloBaseURL;
@property (strong, nonatomic) NSString *userToken;

@property (strong, nonatomic) NSMutableArray *currentDataTasks;

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@property (nonatomic) int boardCount;
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
        
        self.trelloBaseURL = [NSURL URLWithString:@"https://api.trello.com"];
        
        self.userToken = [Lockbox stringForKey:kTrelloUserKey];
        BOOL hasLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:@"SuperminderHasLaunched"];
        if(!hasLaunched || self.userToken == nil){
            self.needsReauthentication = YES;
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate showAuthenticationAlertWithCompletion:^{
                NSString *key = self.apiKey;
                NSString *trelloURL = [NSString stringWithFormat:@"https://trello.com/1/authorize?key=%@&name=Superminder&expiration=never&response_type=token&scope=read,write&callback_method=fragment&return_url=superminder://token", key];
                if([SFSafariViewController class]){
                    UINavigationController *baseNavigationController = (UINavigationController *)appDelegate.window.rootViewController;
                    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:trelloURL]];
                    [baseNavigationController.topViewController presentViewController:safariViewController animated:YES completion:nil];
                }
                else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trelloURL]];
                }
            } client:self];
            return self;
        }
        
        NSURLRequest *urlRequest = [NSURLRequest buildRequestForPath:@"/1/members/me" withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken} relativeToURL:self.trelloBaseURL usingMethod:@"HEAD"];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          if(httpResponse.statusCode == 401){
                                              self.needsReauthentication = YES;
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

- (NSOperationQueue *)operationQueue{
    if(_operationQueue == nil){
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

- (void)setNeedsReauthentication:(BOOL)needsReauthentication{
    self.operationQueue.suspended = needsReauthentication;
    _needsReauthentication = needsReauthentication;
}

- (void)getCurrentUserInfo{
    
    if(self.needsReauthentication){
        [self.operationQueue addOperationWithBlock:^{
            [self getCurrentUserInfo];
            return;
        }];
        return;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest buildRequestForPath:@"/1/members/me" withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken} relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
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

- (void)getAllBoardDataForUser:(SMTrelloUser *)user{
    //TODO: actually make this deal with the user that is passed in
    
    if(self.needsReauthentication){
        [self.operationQueue addOperationWithBlock:^{
            [self getAllBoardDataForUser:user];
        }];
        return;
    }
    
    NSURLRequest *idRequest = [NSURLRequest buildRequestForPath:@"/1/members/me/boards" withParameters:@{ @"filter": @"open", @"key" : self.apiKey, @"token" : self.userToken } relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
    NSURLSessionDataTask *idTask = [self.session dataTaskWithRequest:idRequest completionHandler:
                                    ^(NSData *data, NSURLResponse *response, NSError *error) {
                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                        if(httpResponse.statusCode == 200){
                                            NSError *error;
                                            NSArray *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                            self.boardCount = (int)responseData.count;
                                            for(NSDictionary *board in responseData){
                                                [self getDataForBoard:board[@"id"]];
                                            }
//                                            if(responseData[@"idBoards"] != nil){
//                                                [self getDataForBoardIDs:responseData[@"idBoards"]];
//                                            }
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

    
    NSString *requestPath = [NSString stringWithFormat:@"/1/boards/%@", boardID];
    NSURLRequest *boardRequest = [NSURLRequest buildRequestForPath:requestPath withParameters:@{ @"key" : self.apiKey, @"token" : self.userToken, @"lists" : @"open", @"cards" : @"open" } relativeToURL:self.trelloBaseURL usingMethod:@"GET"];
    
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
                                               for(NSDictionary *cardData in boardData[@"cards"]){
                                                   SMTrelloCard *newCard = [[SMTrelloCard alloc] initWithJSONData:cardData];
                                                   SMTrelloList *cardList = [newBoard listWithID:cardData[@"idList"]];
                                                   [cardList addCard:newCard];
                                               }
                                               [self.delegate boardLoaded:newBoard];
                                               [self boardTaskFinished:boardID];
                                           }
                                       }];
    NSString *taskDesc = [NSString stringWithFormat:@"Fetch board - %@", boardID];
    boardTask.taskDescription = taskDesc;
    NSPredicate *descriptionPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskDescription", taskDesc];
    if([[self.currentDataTasks filteredArrayUsingPredicate:descriptionPredicate] count] == 0){
        [self.currentDataTasks addObject:boardTask];
        [boardTask resume];
    }
}

- (void)boardTaskFinished:(NSString *)boardID{
    
    NSMutableArray *dataTasks = [self.currentDataTasks mutableCopy];
    NSString *taskDescription = [NSString stringWithFormat:@"Fetch board - %@", boardID];
    NSPredicate *descriptionPredicate = [NSPredicate predicateWithFormat:@"%K != %@",@"taskDescription", taskDescription];
    [dataTasks filterUsingPredicate:descriptionPredicate];
    [self.delegate updateProgressValue:((float)(self.boardCount - dataTasks.count) / (float)self.boardCount)];
    if(dataTasks.count == 0){
        [self.delegate allBoardsLoadedForUser:self.currentUser];
    }
    self.currentDataTasks = [dataTasks mutableCopy];
}
@end
