//
//  LevelMap.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 13/7/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "LevelMap.h"

static NSString * const kMapNameKey = @"mapName";
static NSString * const kNumRowKey = @"numRow";
static NSString * const kNumColKey = @"numCol";
static NSString * const kMapDataKey = @"mapData";
static NSString * const kBossTypeKey = @"bossType";

@interface LevelMap ()
@property (nonatomic, strong, readwrite) NSString * mapName;
@property (nonatomic, readwrite) NSUInteger numRow;
@property (nonatomic, readwrite) NSUInteger numCol;
@property (nonatomic, readwrite) NSArray * mapData;
@property (nonatomic, readwrite) BossType bossType;
@end

@implementation LevelMap

- (id)initWithName:(NSString *)mapName
         andNumRow:(NSUInteger)numRow
         andNumCol:(NSUInteger)numCol
        andMapData:(NSArray *)mapData {
    self = [super init];
    if (self) {
        self.mapName = mapName;
        self.numRow = numRow;
        self.numCol = numCol;
        self.mapData = [NSArray arrayWithArray:mapData];
        [self determineBossType];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self) {
        self.mapName = [decoder decodeObjectForKey:kMapNameKey];
        self.mapData = [decoder decodeObjectForKey:kMapDataKey];
        self.numRow = [decoder decodeIntegerForKey:kNumRowKey];
        self.numCol = [decoder decodeIntegerForKey:kNumColKey];
        self.bossType = (BossType)[decoder decodeIntegerForKey:kBossTypeKey];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.mapName forKey:kMapNameKey];
    [coder encodeObject:self.mapData forKey:kMapDataKey];
    [coder encodeInteger:self.numRow forKey:kNumRowKey];
    [coder encodeInteger:self.numCol forKey:kNumColKey];
    [coder encodeInteger:self.bossType forKey:kBossTypeKey];
}

- (void)determineBossType {
    self.bossType = kBossOne;
}
@end
