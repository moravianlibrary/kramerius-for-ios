//
//  MZKConstants.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKConstants : NSObject
FOUNDATION_EXPORT NSString *const kDefaultDatasourceName;
FOUNDATION_EXPORT NSString *const kDefaultDatasourceProtocol;
FOUNDATION_EXPORT NSString *const kDefaultDatasourceStringURL;
FOUNDATION_EXPORT NSString *const kDefaultImageName;


FOUNDATION_EXPORT NSString *const kDatasourceItemChanged;

FOUNDATION_EXPORT NSString *const kRecent;
FOUNDATION_EXPORT NSString *const kRecommended;

#pragma mark - types keys

extern NSString *const kTrack;
extern NSString *const kSoundRecording;
extern NSString *const kVirtualCollection;
extern NSString *const kMonograph;
extern NSString *const kPeriodical;
extern NSString *const kGraphic;
extern NSString *const kManuscript;
extern NSString *const kSheetmusic;
extern NSString *const kMap;




#pragma mark - datasource keys



@end
