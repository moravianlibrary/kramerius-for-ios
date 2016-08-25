//
//  UIApplication+URLEncodedString_ch.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 03/05/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (URLEncodedString_ch)
- (NSString *) URLEncodedString_ch;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end
