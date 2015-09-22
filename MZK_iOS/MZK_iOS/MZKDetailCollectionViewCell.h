//
//  MZKDetailCollectionViewCell.h
//  
//
//  Created by OndrejVyhlidal on 14/09/15.
//
//

#import <UIKit/UIKit.h>

@interface MZKDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemIconImageview;
@property (weak, nonatomic) IBOutlet UIImageView *itemTypeIcon;

@end
