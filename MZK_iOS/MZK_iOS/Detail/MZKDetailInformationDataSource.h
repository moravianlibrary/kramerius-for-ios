//
//  MZKDetailInformationDataSource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetailInformationDelegate <NSObject>

@required
-(void)detailInformationLoaded;
-(void)downloadFailed;

@end

@interface MZKDetailInformationDataSource : NSObject
{
    NSString *baseStringURL;
}

@property (nonatomic, weak) __weak id<DetailInformationDelegate> delegate;

-(void)getDetailInformationAboutDocument:(NSString *)pid;

@end
