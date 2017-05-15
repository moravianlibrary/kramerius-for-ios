//
//  MZKConstants.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKConstants.h"

@implementation MZKConstants

int const kMinimalRecentSearchesVersion = 3;
int const kMinimalRecentDocumentsVersion = 2;
int const kMinimalLibrariesCacheVersionNumber = 1;
int const kMinimalBookmarkVerion = 1;
int const kLibrariesViewControllerIndex = 3;

NSString *const kConnectionRestoredNotification = @"kConnectionRestoredNotification";

NSString *const kDefaultDatasourceItem = @"kDefaultDatasourceItem";
NSString *const kDefaultDatasourceName = @"kDefaultDatasourceName";
NSString *const kDefaultDatasourceProtocol = @"kDefaultDatasourceProtocol";
NSString *const kDefaultDatasourceStringURL = @"kDefaultDatasourceStringURL";
NSString *const kDefaultImageName = @"kDefaultDatasourceImageName";
NSString *const kDatasourceItemChanged = @"kDatasourceItemChanged";
NSString *const kRecent = @"recent";
NSString *const kRecommended = @"recommended";
NSString *const kRecentMusicPlayed = @"recentMusic";
NSString *const kSettingsShowOnlyPublicDocuments = @"showOnlyPublicDocuments";
NSString *const kRecentlyOpenedDocuments = @"kRecentlyOpenedDocuments";
NSString *const kRecentlyOpenedDocumentsVersion = @"kRecentlyOpenedDocumentsVersion";
NSString *const kRecentSearches = @"kRecentSearches";
NSString *const kShouldDimmDisplay = @"kShouldDimmDisplay";
NSString *const kMinimalRecentSearches = @"kMinimalRecentSearches";
NSString *const kMinimalLibrariesCacheVersion = @"kMinimalLibrariesCacheVersion";
NSString *const kMinimalBookmarkVersionKey =@"kMinimalBookmarkVersionKey";
NSString *const kAllBookmarks = @"kAllBookmarks";

#pragma mark - types keys

NSString *const kTrack = @"track";
NSString *const kSoundRecording = @"soundrecording";
NSString *const kSheetmusic = @"sheetmusic";
NSString *const kSoundUnit = @"soundUnit";


NSString *const kVirtualCollection= @"virtualcollection";
NSString *const kMonograph= @"monograph";
NSString *const kPeriodical= @"periodical";
NSString *const kPeriodicalVolume= @"periodicalVolume";
NSString *const kPeriodicalItem= @"periodicalItem";
NSString *const kGraphic= @"graphic";
NSString *const kManuscript= @"manuscript";

NSString *const kMap= @"map";
NSString *const kPage= @"page";
NSString *const kPhoto= @"photo";
NSString *const kArchive= @"archive";
NSString *const kBook= @"book";
NSString *const kGroup= @"group";
NSString *const kLabel= @"label";
NSString *const kLock= @"lock";
NSString *const kMusic= @"music";
NSString *const kVinil= @"vinil";
NSString *const kArticle = @"article";
NSString *const kSupplement = @"supplement";
NSString *const kInternalPart = @"internalpart";

#pragma mark - czech translations
NSString *const kKrameriusDescription = @"Aplikace zpřístupňuje digitální fondy českých knihoven. Najdete zde dokumenty, které již nepodléhají autorskému zákonu - beletrii, staré noviny a časopisy, archiválie, rukopisy, kolekce map, gramodesky a další.";
NSString *const kKrameriusDescriptionContact=@"Máte-li jakékoliv připomínky, otázky nebo nápady, kontaktujte nás prosím na ";
NSString *const kKramerisuDescriptionContactMail =@"developer@mzk.cz.";
NSString *const kKrameriusDescriptionBegin=@"Aplikaci vyvíjí";
NSString *const kKrameriusDescriptionLink=@"http://www.mzk.cz/";

NSString *const kDocumentPeriodical = @"Noviny a časopisy";
NSString *const kDocumentPeriodicalVolume= @"Ročník periodika";
NSString *const kDocumentPeriodicalItem = @"Číslo periodika";
NSString *const kDocumentPage = @"Stránka";
NSString *const kDocumentManuscript= @"Rukopis";
NSString *const kDocumentMonograph = @"Kniha";
NSString *const kDocumentSoundRecording = @"Zvukové nahrávky";
NSString *const kDocumentSoundUnit = @"Zvukový nosič";
NSString *const kDocumentTrack = @"Nahrávka";
NSString *const kDocumentMap = @"Mapa";
NSString *const kDocumentGraphic = @"Grafika";
NSString *const kDocumentSheetmusic = @"Hudebniny";
NSString *const kDocumentArchive = @"Archiválie";
NSString *const kDocumentUnknown = @"Neznámý typ";
NSString *const kDocumentArticle = @"Článek";
NSString *const kDocumentSupplement = @"Příloha";
NSString *const kDocumentInternalpart =@"Vnitřní část";

+ (NSString*)modelTypeToString:(MZKModel)model {
    NSString *result = kDocumentUnknown;
 
    switch(model) {
        case Monograph:
            result = kMonograph;
            break;
        case Periodical:
            result = kPeriodical;
            break;
        case PeriodicalItem:
            result = kPeriodicalItem;
            break;
        case PeriodicalVolume:
            result = kPeriodicalVolume;
            break;
        case Map:
            result = kMap;
            break;
        case Manuscript:
            result = kManuscript;
            break;
        case Graphic:
            result = kGraphic;
            break;
        case Archive:
            result = kArchive;
            break;
        case Article:
            result =kArticle;
            break;
        case Sheetmusic:
            result = kSheetmusic;
            break;
        case Page:
            result = kPage;
            break;
        case Supplement:
            result = kSupplement;
            break;
            
        case InternalPart:
            result = kInternalPart;
            break;
        case SoundUnit:
            result = kSoundUnit;
            break;
        case SoundRecording:
            result = kSoundRecording;
            break;
        case Track:
            result = kTrack;
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected Model Type."];
            result = kDocumentUnknown;
    }
    
    
    return result;
}

+ (MZKModel)stringToModel:(NSString *)strToModel
{
    MZKModel tmpModel = Unknown;
    
    if ([strToModel caseInsensitiveCompare:kMonograph] == NSOrderedSame) {
        tmpModel = Monograph;
        
    }else if ([strToModel caseInsensitiveCompare:kPeriodical]== NSOrderedSame) {
        tmpModel = Periodical;
    }else if ([strToModel caseInsensitiveCompare:kPeriodicalItem]== NSOrderedSame) {
        tmpModel = PeriodicalItem;
    }else if ([strToModel caseInsensitiveCompare:kPeriodicalVolume]== NSOrderedSame) {
        tmpModel = PeriodicalVolume;
    }else if ([strToModel caseInsensitiveCompare:kMap]== NSOrderedSame) {
        tmpModel = Map;
    }else if ([strToModel caseInsensitiveCompare:kGraphic]== NSOrderedSame) {
        tmpModel = Graphic;
    }else if ([strToModel caseInsensitiveCompare:kArchive]== NSOrderedSame) {
        tmpModel = Archive;
    }else if ([strToModel caseInsensitiveCompare:kSheetmusic]== NSOrderedSame) {
        tmpModel = Sheetmusic;
    }else if ([strToModel caseInsensitiveCompare:kManuscript]== NSOrderedSame) {
        tmpModel = Manuscript;
    }else if ([strToModel caseInsensitiveCompare:kPage]== NSOrderedSame) {
        tmpModel = Page;
    }else if ([strToModel caseInsensitiveCompare:kSupplement]== NSOrderedSame) {
        tmpModel = Supplement;
    }else if ([strToModel caseInsensitiveCompare:kArticle]== NSOrderedSame) {
        tmpModel =  Article;
    }else if ([strToModel caseInsensitiveCompare:kInternalPart]== NSOrderedSame) {
        tmpModel = InternalPart;
    }else if ([strToModel caseInsensitiveCompare:kSoundUnit]== NSOrderedSame) {
        tmpModel = SoundUnit;
    }else if ([strToModel caseInsensitiveCompare:kSoundRecording]== NSOrderedSame) {
        tmpModel = SoundRecording;
    } else if ([strToModel caseInsensitiveCompare:kTrack]== NSOrderedSame) {
            tmpModel = Track;
    }
    
    return tmpModel;
    
}



@end
