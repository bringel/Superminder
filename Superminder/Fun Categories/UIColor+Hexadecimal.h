//
//  UIColor.h
//  Superminder
//
//  Created by Bradley Ringel on 10/4/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

@interface UIColor (Hexadecimal)

+ (UIColor *)colorWithHexadecimalColor:(NSString *)hexString;

- (instancetype)initWithHexadecimalColor:(NSString *)hexString;

@end
