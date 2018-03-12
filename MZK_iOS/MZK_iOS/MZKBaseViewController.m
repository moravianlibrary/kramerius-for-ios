//
//  MZKBaseViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 28/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKBaseViewController.h"


@interface MZKBaseViewController ()
@end

@implementation MZKBaseViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle withCompletion:(void (^)())actionBlock
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:subtitle
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];

                             }];

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:actionBlock];

}
@end
