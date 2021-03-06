 //
//  SQLManager.m
//  Fmdb_manipulate
//
//  Created by vedon on 23/9/13.
//  Copyright (c) 2013 com.vedon. All rights reserved.
//

#import "SQLManager.h"
#import "FMDatabase.h"
#import "OrderType.h"
@implementation SQLManager
@synthesize db;


//创建数据库
-(id)initDataBase
{
    self = [super init];
    if (self) {
        NSString *dataPath = [self initializationFilePath];
        NSLog(@"%@",dataPath);
        self.db = [FMDatabase databaseWithPath:dataPath];
        if (![db open]) {
            NSLog(@"Open db error");
        }else
        {
            NSLog(@"open db successfully");
        }

    }
    return  self;
}
//创建数据表
-(void)createTable
{
    NSString * createTableStr = @"create table if not exists iFindTable(uuid text primary key,name text,image text,alertDistance integer,alertTime integer,alertMusic text,phoneMode text,deviceMode text,blueMode text,vibrate text,targetTag text)";
    if ([db executeUpdate:createTableStr]) {
        NSLog(@"create table successfully");
    }else
    {
        NSLog(@"Fail to create table,Error: %@",[db lastError]);
    }
}

//插入数据到数据表
-(void)insertTableWithUUID:(NSString *)uuid Tag:(NSInteger )tag
{
    
    if (![self getValue:UUIDStr ByUUID:uuid]) {
        NSString *defaultName = nil;
        NSString *defaultImage = nil;
        switch (tag) {
            case TagOne:
                defaultName = TagOneName;
                defaultImage = TagOneImageH;
                break;
            case TagTwo:
                defaultName = TagTwoName;
                defaultImage = TagTwoImageH;
                break;
            case TagThree:
                defaultName = TagThreeName;
                defaultImage = TagThreeImageH;
                break;
            case TagFour:
                defaultName = TagFourName;
                defaultImage = TagFourImageH;
                break;
                
            default:
                break;
        }
        [self insertValueToExistedTableWithArguments:@[uuid,defaultName,defaultImage,DistanceFar,AlertTime10,DefaultMusic,PhoneModeVibrate,DeviceModeLightSound,ModeMutualAlertStop,VibrateOn,[NSNumber numberWithInt:tag]]];
    }
    
}


-(void)insertValueToExistedTableWithArguments:(NSArray *)array
{
    NSLog(@"Insert Data array :%@",array);
    if ([db executeUpdate:@"insert into iFindTable values(?,?,?,?,?,?,?,?,?,?,?)" withArgumentsInArray:array]) {
        NSLog(@"Insert value successfully");
    }else
    {
        NSLog(@"Failer to insert value to table,Error: %@",[db lastError]);
    }
}

//更新数据库数据
-(void)updateKey:(NSString *)key value:(NSString *)value withUUID:(NSString *)uuid
{
    NSString *sqlStr = [NSString stringWithFormat:@"update iFindTable set %@=? where uuid=?",key];
    if ([db executeUpdate:sqlStr,value,uuid]) {
        NSLog(@"update value successfully");
    }else
    {
        NSLog(@"Fail to update value to table,Error: %@",[db lastError]);
    }
}
//查询记录
-(NSDictionary *)queryDatabaseWithUUID:(NSString *)uuid
{
    NSLog(@"%s",__func__);
    NSMutableDictionary * deviceInfoDic = [[NSMutableDictionary alloc]init];
    FMResultSet *rs = [db executeQuery:@"select * from iFindTable where uuid=?",uuid];
    while ([rs next]) {
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"uuid"]   forKey:UUIDStr];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"name"]   forKey:DeviceName];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"image"]  forKey:ImageName];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"alertDistance"] forKey:DistanceValue];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"alertTime"]  forKey:AlertTime];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"alertMusic"]   forKey:AlertMusic];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"phoneMode"]   forKey:PhoneMode];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"deviceMode"]   forKey:DeviceMode];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"blueMode"]   forKey:BluetoothMode];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"vibrate"]   forKey:VibrateMode];
        [deviceInfoDic setObject:[self returnDataObjWith:rs keyWord:@"targetTag"]   forKey:TargetTag];

    }
    [rs close];
    return deviceInfoDic;
}

-(NSString *)returnDataObjWith:(FMResultSet *)resultSet keyWord:(NSString *)keyStr
{

    NSString *tempStr = nil;
    tempStr = [resultSet stringForColumn:keyStr];
    if (tempStr) {
        return tempStr;
    }else
    {
        tempStr = @"NULL";
        return tempStr;
    }

}
//删除行记录
-(void)deleteDatabaseRowWithUUID:(NSString *)uuid
{
    if ([db executeUpdate:@"delete from iFindTable where uuid=?",uuid]) {
        NSLog(@"update value successfully");
    }else
    {
        NSLog(@"Failer to update value to table,Error: %@",[db lastError]);
    }
}

//返回对应uuid 的value 值
-(NSString *)getValue:(NSString *)value ByUUID:(NSString *)uuid
{
    NSString *quertStr = [[NSString alloc]initWithFormat:@"select %@ from iFindTable where uuid=?",value];
    FMResultSet *rs = [db executeQuery:quertStr,uuid];
    while ([rs next])
    {
        return  [rs stringForColumn:value];
    }
    return nil;
}


//返回对应uuid 的value 值
-(NSString *)getValue:(NSString *)value ByTag:(int)tag
{
    NSString *quertStr = [[NSString alloc]initWithFormat:@"select %@ from iFindTable where targetTag=?",value];
    FMResultSet *rs = [db executeQuery:quertStr,[NSNumber numberWithInt:tag]];
    while ([rs next])
    {
        return  [rs stringForColumn:value];
    }
    return nil;
}

//数据库文件路径
-(NSString *)initializationFilePath
{
    NSString * tempFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [tempFilePath stringByAppendingPathComponent:@"DataBase.db"];
    return filePath;
}

-(void)dealloc
{
    [self.db close];
    [self.db release];
    [super dealloc];
}
@end
