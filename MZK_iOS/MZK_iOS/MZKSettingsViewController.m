//
//  MZKSettingsViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 21/12/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKSettingsViewController.h"

@interface MZKSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *publicDocuments;

@end

@implementation MZKSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)publicDocumentsUIsliderValueChanged:(id)sender {
    
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
