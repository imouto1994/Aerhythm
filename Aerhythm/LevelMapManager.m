//
//  LevelMapManager.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 8/7/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "LevelMapManager.h"
#import "Utilities.h"
#import "FacebookHelper+Aerhythm.h"

static NSString * const kLocalLevelMapListFileName = @"localLevelMapList.plist";
static NSString * const kLocalMapListKey = @"localLevelMapList";
static NSString * const kLocalMapKey = @"localLevelMap";

@implementation LevelMapManager

+ (BOOL)storeLevelMap:(LevelMap *)levelMap {
    if (!levelMap) {
        return YES;
    }
    
    NSMutableData * data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:levelMap forKey:kLocalMapKey];
    [archiver finishEncoding];
    
    NSString * path = [LevelMapManager getFilePathForLevelMapWithName:levelMap.mapName];
    if ([data writeToFile:path atomically:YES]) {
        NSMutableArray * localMapList = [NSMutableArray arrayWithArray:
                                         [LevelMapManager getLocalLevelMapNames]];
        [localMapList addObject:levelMap.mapName];
        NSDictionary * localMapListDict = [NSDictionary dictionaryWithObject:localMapList
                                                                      forKey:kLocalMapListKey];
        
        NSString * documentPath = [Utilities documentsDirectory];
        NSString * plistPath = [documentPath stringByAppendingPathComponent:
                                kLocalLevelMapListFileName];
        [localMapListDict writeToFile:plistPath atomically:YES];
        
        return YES;
    }
    
    return NO;
}

+ (LevelMap *)loadLevelMapWithName:(NSString *)mapName {
    NSString * path = [LevelMapManager getFilePathForLevelMapWithName:mapName];
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    LevelMap * localMap = [unarchiver decodeObjectForKey:kLocalMapKey];
    [unarchiver finishDecoding];
    
    return localMap;
}

+ (NSArray *)getLocalLevelMapNames {
    NSArray * localMapList = [[NSArray alloc] init];
    NSString * documentPath = [Utilities documentsDirectory];
    NSString * plistPath = [documentPath stringByAppendingPathComponent:kLocalLevelMapListFileName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]) {
        NSDictionary * plistContent = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        localMapList = [plistContent objectForKey:kLocalMapListKey];
    }
    return localMapList;
}

+ (NSString *)getFilePathForLevelMapWithName:(NSString *)mapName {
    // EFFECTS: Gets the path of file containing map data for level map with input name
    NSString * documentPath = [Utilities documentsDirectory];
    return [documentPath stringByAppendingString:
            [NSString stringWithFormat:@"%@.out", mapName]];
}

@end
