//
//  LevelMapManager.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 8/7/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelMap.h"

@interface LevelMapManager : NSObject

+ (BOOL)storeLevelMap:(LevelMap *)levelMap;

+ (LevelMap *)loadLevelMapWithName:(NSString *)mapName;

+ (NSArray *)getLocalLevelMapNames;

@end
