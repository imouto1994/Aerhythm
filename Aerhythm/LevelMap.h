//
//  LevelMap.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 13/7/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface LevelMap : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString * mapName;
@property (nonatomic, readonly) NSUInteger numRow;
@property (nonatomic, readonly) NSUInteger numCol;
@property (nonatomic, readonly) NSArray * mapData;
@property (nonatomic, readonly) BossType bossType;

- (id)initWithName:(NSString *)mapName
         andNumRow:(NSUInteger)numRow
         andNumCol:(NSUInteger)numCol
        andMapData:(NSArray *)mapData;

@end
