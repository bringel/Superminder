//
//  SMLoginViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMLoginViewController.h"
#import "SMTrelloClient.h"
#import "OnePasswordExtension.h"
#import "Lockbox.h"

@interface SMLoginViewController ()  <UIWebViewDelegate>

@end

@implementation SMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *key = [[SMTrelloClient sharedClient] apiKey];
    NSString *trelloURL = [NSString stringWithFormat:@"https://trello.com/1/authorize?key=%@&name=Superminder&expiration=never&response_type=token&scope=read,write&callback_method=fragment&return_url=superminder://token", key];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:trelloURL]];
    self.webView.delegate = self;
    [self.webView loadRequest:urlRequest];
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
    if(![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]){
        self.navigationController.navigationItem.rightBarButtonItems = @[];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)activateOnePassword:(id)sender{
    [[OnePasswordExtension sharedExtension] fillLoginIntoWebView:self.webView forViewController:self sender:sender completion:^(BOOL success, NSError *error) {
        
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *requestURL = request.URL;
    if([[requestURL scheme] isEqualToString:@"superminder"]){
        NSArray *fragmentPieces = [requestURL.fragment componentsSeparatedByString:@"="];
        if([[fragmentPieces objectAtIndex:0] isEqualToString:@"token"]){
            [Lockbox setString:[fragmentPieces objectAtIndex:1] forKey:kTrelloUserKey];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Navigation

- (IBAction)cancelLogin:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
