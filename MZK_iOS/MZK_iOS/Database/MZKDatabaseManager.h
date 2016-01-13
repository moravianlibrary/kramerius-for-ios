//
//  MZKDatabaseManager.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface MZKDatabaseManager : NSObject
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;





-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(void)executeQuery:(NSString *)query;
-(NSArray *)loadDataFromDB:(NSString *)query;



@end
