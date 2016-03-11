//
//  MZKBaseViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 28/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZKBaseViewController : UIViewController


-(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
-(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle;
-(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle confirmAction:(void (^)())actionBlock;
-(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle withCompletion:(void (^)())actionBlock;


@end
