//
//  EnemyFactory.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 23/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "EnemyJet.h"

@interface EnemyFactory : NSObject
+ (EnemyJet *)createEnemyJetWithType:(EnemyType)enemyType andAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire;
// EFFECTS: Factory method that creates an instance of EnemyJet based on the input enemy type

+ (EnemyJet *)createEnemyJetWithType:(EnemyType)enemyType andAtPosition:(CGPoint)position;
// EFFECTS: Factory method that creates an instance of EnemyJet based on the input enemy type

+ (void)loadSharedAssetsForEnemyTypes:(NSArray *)enemyTypeArray;
// EFFECTS: Loads shared assets (e.g. images) for all enemy types

+ (void)loadsharedAssetsForEnemyType:(EnemyType)enemyType;
// EFFECTS: Loads shared assets (e.g. images) for the input enemy type

+ (void)releaseSharedAssets;
// EFFECTS: Releases shared assets (e.g. images) for all enemy types

+ (CGFloat)getRadiusOfEnemyType:(EnemyType)type;
// EFFECTS: Returns the radius of the input enemy type

@end
