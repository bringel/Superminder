//
//  UIColor.m
//  Superminder
//
//  Created by Bradley Ringel on 10/4/15.
//  Copyright © 2015 Bradley Ringel. All rights reserved.
//

#import "UIColor+Hexadecimal.h"

@implementation UIColor (Hexadecimal)

+ (UIColor *)colorWithHexadecimalColor:(NSString *)hexString{
    return [[UIColor alloc] initWithHexadecimalColor:hexString];
}

- (instancetype)initWithHexadecimalColor:(NSString *)hexString{
    //taken from FCUtilities by Marco Arment
    unsigned int hexInt,redBit,greenBit,blueBit;
    if(![hexString isKindOfClass:[NSString class]]){
        return nil;
    }
    if([hexString hasPrefix:@"#"]){ //get rid of # if it was part of the string so NSScanner will recognize the int.
        hexString = [hexString substringFromIndex:1];
    }
    NSScanner *hexScanner = [[NSScanner alloc] initWithString:hexString];
    [hexScanner scanHexInt:&hexInt];
    redBit = (hexInt & 0xFF0000) >> 16;
    greenBit = (hexInt & 0xFF00) >> 8;
    blueBit = (hexInt & 0xFF);
    
    return [UIColor colorWithRed:((float)redBit/255.0) green:((float)greenBit/255.0) blue:((float)blueBit/255.0) alpha:1.0];
}

@end
