//
//  MZKConstants.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

// model enum

typedef NS_ENUM(NSInteger, MZKModel) {
    Monograph,
    Periodical,
    Map,
    Graphic,
    Archive,
    Sheetmusic,
    PeriodicalVolume,
    PeriodicalItem,
    Manuscript,
    Page,
    Supplement,
    Article,
    InternalPart,
    SoundRecording,
    SoundUnit,
    Track,
    Unknown
};

@interface MZKConstants : NSObject
extern int const kMinimalRecentSearchesVersion;
extern int const kMinimalRecentDocumentsVersion;
extern int const kMinimalLibrariesCacheVersionNumber;
extern int const kMinimalBookmarkVerion;
extern int const kLibrariesViewControllerIndex;

extern NSString *const kConnectionRestoredNotification;

#pragma mark - NSUserDefaults keys
extern NSString *const kDefaultDatasourceItem;
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
extern NSString *const kMinimalRecentSearches;
extern NSString *const kMinimalLibrariesCacheVersion;
extern NSString *const kAllBookmarks;
extern NSString *const kMinimalBookmarkVersionKey;

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
extern NSString *const kArticle;
extern NSString *const kSupplement;
extern NSString *const kInternalPart;

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
extern NSString *const kDocumentArticle;
extern NSString *const kDocumentSupplement;
extern NSString *const kDocumentInternalpart;

// convinience methods
+ (NSString*)modelTypeToString:(MZKModel)model;
+ (MZKModel)stringToModel:(NSString *)strToModel;

+ (BOOL)isMusic:(MZKModel)model;

@end
