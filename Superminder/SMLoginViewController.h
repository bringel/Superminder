//
//  SMLoginViewController.h
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface SMLoginViewController : UIViewController

@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *onePasswordItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;

@end
