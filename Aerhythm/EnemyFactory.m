//
//  EnemyFactory.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 23/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "EnemyFactory.h"
#import "FireEnemy.h"
#import "DefaultEnemy.h"
#import "NinjaEnemy.h"
#import "IceEnemy.h"
#import "SuicideEnemy.h"
#import "RockEnemy.h"
#import "ShockEnemy.h"
#import "FirstBoss.h"
#import "SecondBoss.h"
#import "ThirdBoss.h"
#import "FourthBoss.h"

@implementation EnemyFactory

+ (EnemyJet *)createEnemyJetWithType:(EnemyType)enemyType andAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire{
    switch (enemyType) {
        case kFireEnemy:
            return [[FireEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kDefaultEnemy:
            return [[DefaultEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kNinjaEnemy:
            return [[NinjaEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kIceEnemy:
            return [[IceEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kSuicideEnemy:
            return [[SuicideEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kRockEnemy:
            return [[RockEnemy alloc] initAtPosition:position enableFire:isEnableFire];
                    
        case kShockEnemy:
            return [[ShockEnemy alloc] initAtPosition:position enableFire:isEnableFire];
            
        case kFirstBoss:
            return [[FirstBoss alloc] initAtPosition:position];
            
        case kSecondBoss:
            return [[SecondBoss alloc] initAtPosition:position];
            
        case kThirdBoss:
            return [[ThirdBoss alloc] initAtPosition:position];
            
        case kFourthBoss:
            return [[FourthBoss alloc] initAtPosition:position];
            
        default:
            return nil;
    }
}

+ (EnemyJet *)createEnemyJetWithType:(EnemyType)enemyType andAtPosition:(CGPoint)position
{
    // EFFECTS: Factory method that creates an instance of EnemyJet based on the input enemy type
    
    switch (enemyType) {
        case kFireEnemy:
            return [[FireEnemy alloc] initAtPosition:position];
            
        case kDefaultEnemy:
            return [[DefaultEnemy alloc] initAtPosition:position];
            
        case kNinjaEnemy:
            return [[NinjaEnemy alloc] initAtPosition:position];
            
        case kIceEnemy:
            return [[IceEnemy alloc] initAtPosition:position];
            
        case kSuicideEnemy:
            return [[SuicideEnemy alloc] initAtPosition:position];
        
        case kRockEnemy:
            return [[RockEnemy alloc] initAtPosition:position];
            
        case kShockEnemy:
            return [[ShockEnemy alloc] initAtPosition:position];
        
        case kFirstBoss:
            return [[FirstBoss alloc] initAtPosition:position];
        
        case kSecondBoss:
            return [[SecondBoss alloc] initAtPosition:position];
            
        case kThirdBoss:
            return [[ThirdBoss alloc] initAtPosition:position];
            
        case kFourthBoss:
            return [[FourthBoss alloc] initAtPosition:position];
            
        default:
            return nil;
    }
    
    // Dummy code
    return nil;
}

+ (void)loadsharedAssetsForEnemyType:(EnemyType)enemyType
{
    // EFFECTS: Loads shared assets (e.g. images) for the input enemy type
    NSArray * array = @[[NSNumber numberWithUnsignedInteger:(NSUInteger)enemyType]];
    [EnemyFactory loadSharedAssetsForEnemyTypes:array];
}

+ (void)loadSharedAssetsForEnemyTypes:(NSArray *)enemyTypeArray
{
    // EFFECTS: Loads shared assets (e.g. images) for all enemy types
    for (NSNumber * typeNsNumber in enemyTypeArray) {
        EnemyType enemyType = (EnemyType) [typeNsNumber unsignedIntegerValue];
        switch (enemyType) {
            case kFireEnemy:
                [FireEnemy loadSharedAssets];
                break;
            case kDefaultEnemy:
                [DefaultEnemy loadSharedAssets];
                break;
            case kNinjaEnemy:
                [NinjaEnemy loadSharedAssets];
                break;
            case kIceEnemy:
                [IceEnemy loadSharedAssets];
                break;
            case kSuicideEnemy:
                [SuicideEnemy loadSharedAssets];
                break;
            case kRockEnemy:
                [RockEnemy loadSharedAssets];
                break;
            case kShockEnemy:
                [ShockEnemy loadSharedAssets];
                break;
            case kFirstBoss:
                [FirstBoss loadSharedAssets];
                break;
            case kSecondBoss:
                [SecondBoss loadSharedAssets];
                break;
            case kThirdBoss:
                [ThirdBoss loadSharedAssets];
                break;
            case kFourthBoss:
                [FourthBoss loadSharedAssets];
                break;
            default:
                break;
        }
    }
}

+ (void)releaseSharedAssets
{
    // EFFECTS: Releases shared assets (e.g. images) for all enemy types
    
    [FireEnemy releaseSharedAssets];
    [DefaultEnemy releaseSharedAssets];
    [NinjaEnemy releaseSharedAssets];
    [IceEnemy releaseSharedAssets];
    [SuicideEnemy releaseSharedAssets];
    [RockEnemy releaseSharedAssets];
    [ShockEnemy releaseSharedAssets];
    [FirstBoss releaseSharedAssets];
    [SecondBoss releaseSharedAssets];
    [ThirdBoss releaseSharedAssets];
    [FourthBoss releaseSharedAssets];
}

+ (CGFloat)getRadiusOfEnemyType:(EnemyType)type
{
    // EFFECTS: Returns the radius of the input enemy type
    
    switch (type) {
        case kFireEnemy:
            return 64;
        case kDefaultEnemy:
            return 48;
        case kNinjaEnemy:
            return 72;
        case kIceEnemy:
            return 56;
        case kSuicideEnemy:
            return 72;
        case kRockEnemy:
            return 72;
        case kShockEnemy:
            return 56;
        case kFirstBoss:
            return 100;
        case kSecondBoss:
            return 100;
        case kThirdBoss:
            return 100;
        case kFourthBoss:
            return 100;
        case kNoEnemy:
            return 0;
    }
}
@end
