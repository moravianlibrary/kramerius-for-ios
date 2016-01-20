//
//  MZKAboutViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 15/12/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKAboutViewController.h"
#import "TTTAttributedLabel.h"
#import "MZKConstants.h"

@interface MZKAboutViewController ()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *mailContact;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *link;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end

@implementation MZKAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mailContact.delegate = self;
    [self.mailContact setText:[NSString stringWithFormat:@"%@ (%@)",kKrameriusDescriptionContact,kKramerisuDescriptionContactMail]];

    self.link.delegate = self;
    self.link.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    

    [self.link setText:[NSString stringWithFormat:@"%@, Moravská zemská knihovna v Brně. (%@)",kKrameriusDescriptionBegin,kKrameriusDescriptionLink]];
       
    NSRange range = [self.link.text rangeOfString:@"Moravská zemská knihovna v Brně."];
    [self.link addLinkToURL:[NSURL URLWithString:kKrameriusDescriptionLink] withRange:range]; // Embedding a custom link in a substring
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

#pragma mark -
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([label isEqual:self.link]) {
        
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mzk.cz/"]];
    }
}
- (IBAction)onBack:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end