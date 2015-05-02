//
//  SMLoginViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMLoginViewController.h"
#import "SMTrelloClient.h"

@interface SMLoginViewController ()

@end

@implementation SMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];
    NSString *key = [[SMTrelloClient sharedClient] apiKey];
    NSString *trelloURL = [NSString stringWithFormat:@"https://trello.com/1/authorize?key=%@&name=Superminder&expiration=never&response_type=token&scope=read,write&callback_method=postMessage&return_url=superminder://token", key];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:trelloURL]];
    
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
