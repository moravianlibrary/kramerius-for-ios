//
//  MZKHeaderView.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 16/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKHeaderView.h"

@implementation MZKHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (IBAction)segmentControllValueChanged:(UISegmentedControl *)sender
{
    switch (_headerSwitch.selectedSegmentIndex) {
        case 0:
            //TODO call delegate
          //  [_collectionView reloadData];
            
            if (_delegate) {
                [_delegate firstIndexSelected];
            }
            break;
            
        case 1:
            // todo call delegate
         //   [_collectionView reloadData];
            if (_delegate) {
                [_delegate secondIndexSelected];
            }
            break;
            
        default:
            break;
    }
}

-(void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"MZKHeaderView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

@end
