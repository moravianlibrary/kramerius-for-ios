//
//  MZKConstants.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKConstants : NSObject
#pragma mark - NSUserDefaults keys
extern NSString *const kDefaultDatasourceName;
extern NSString *const kDefaultDatasourceProtocol;
extern NSString *const kDefaultDatasourceStringURL;
extern NSString *const kDefaultImageName;
extern NSString *const kDatasourceItemChanged;
extern NSString *const kRecent;
extern NSString *const kRecommended;
extern NSString *const kRecentMusicPlayed;
extern NSString *const kSettingsShowOnlyPublicDocuments;
extern NSString *const kRecentlyOpenedDocuments;
extern NSString *const kRecentlyOpenedDocumentsVersion;
extern NSString *const kRecentSearches;
extern NSString *const kShouldDimmDisplay;

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
extern NSString *const kPage;
extern NSString *const kPhoto;
extern NSString *const kArchive;
extern NSString *const kBook;
extern NSString *const kGroup;
extern NSString *const kLabel;
extern NSString *const kLock;
extern NSString *const kMusic;
extern NSString *const kVinil;
extern NSString *const kPeriodicalVolume;
extern NSString *const kPeriodicalItem;
extern NSString *const kSoundUnit;

#pragma mark - datasource keys
extern NSString *const kKrameriusDescription;
extern NSString *const kKrameriusDescriptionContact;
extern NSString *const kKrameriusDescriptionBegin;
extern NSString *const kKrameriusDescriptionLink;
extern NSString *const kKramerisuDescriptionContactMail;

#pragma mark - czech translations
extern NSString *const kDocumentPeriodical ;
extern NSString *const kDocumentPeriodicalVolume;
extern NSString *const kDocumentPeriodicalItem;
extern NSString *const kDocumentPage;
extern NSString *const kDocumentManuscript;
extern NSString *const kDocumentMonograph;
extern NSString *const kDocumentSoundRecording;
extern NSString *const kDocumentSoundUnit;
extern NSString *const kDocumentTrack ;
extern NSString *const kDocumentMap ;
extern NSString *const kDocumentGraphic ;
extern NSString *const kDocumentSheetmusic;
extern NSString *const kDocumentArchive;
extern NSString *const kDocumentUnknown ;



@end
