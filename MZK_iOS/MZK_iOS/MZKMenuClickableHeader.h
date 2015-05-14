//
//  MZKMenuClickableHeader.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol MenuClickableHeaderDelegate <NSObject>

@required
-(void)onMenuHeader;

@end



@interface MZKMenuClickableHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *libraryIcon;
@property (weak, nonatomic) IBOutlet UILabel *libraryName;
@property (weak, nonatomic) IBOutlet UILabel *libraryInfo;

@property (weak, nonatomic) IBOutlet UIButton *headerButton;
- (IBAction)onHeader:(id)sender;


@property (nonatomic, weak) id<MenuClickableHeaderDelegate> delegate;

@end
