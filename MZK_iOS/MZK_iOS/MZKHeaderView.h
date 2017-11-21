//
//  MZKHeaderView.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 16/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol SegmentDelegate;

// 3. Definition of the delegate's interface
@protocol SegmentDelegate <NSObject>

@required
- (void)headerSwitchValueChanged:(UISegmentedControl *)segmentControll withValue:(NSInteger) selectedSegmentIndex;

@optional
-(void)firstIndexSelected;
-(void)secondIndexSelected;
@end
    


@interface MZKHeaderView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak) id<SegmentDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headerSwitch;

@end
