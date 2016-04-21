//
//  MZKSettingsViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 21/12/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKSettingsViewController.h"
#import "AppDelegate.h"
#import "MZKConstants.h"

@interface MZKSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *publicDocuments;

@end

@implementation MZKSettingsViewController

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.settings", @"application settings screen title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.settings", @"application settings screen title");
    [self loadSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClose:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)loadSettings
{
   //kSettingsShowOnlyPublicDocuments
    
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    if (recent) {
       BOOL visible = [recent boolValue];
    
        [self.publicDocuments setOn: visible];
    }
}

- (IBAction)publicDocumentsUIsliderValueChanged:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.publicDocuments.on] forKey:kSettingsShowOnlyPublicDocuments];
     [[NSNotificationCenter defaultCenter] postNotificationName:kDatasourceItemChanged object:nil];
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
