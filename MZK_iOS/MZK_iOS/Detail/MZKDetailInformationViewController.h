//
//  MZKDetailInformationViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MZKBaseViewController;
//#import "MZKBaseViewController.h"

@interface MZKDetailInformationViewController : UIViewController
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *rootPID;
@property (weak, nonatomic) IBOutlet UILabel *model;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UILabel *language;
@property (weak, nonatomic) IBOutlet UILabel *author;

@property (weak, nonatomic) IBOutlet UILabel *publisherName;
@property (weak, nonatomic) IBOutlet UILabel *yearOfPublishing;
@property (weak, nonatomic) IBOutlet UILabel *placeOfPublishing;
@property (weak, nonatomic) IBOutlet UILabel *placeOfStorage;
@property (weak, nonatomic) IBOutlet UILabel *numberOfShelf;
-(void)setItem:(NSString *)item;

@end
