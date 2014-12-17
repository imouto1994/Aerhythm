//
//  Powerup.m
//  Aerhythm
//
//  Created by Nguyen Ngoc Nhu Thao on 3/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "Powerup.h"
#import "GameUpgrade.h"

#define kRadius 48
#define kSpeed 200

#define kSpriteName @"powerup"
#define kPowerupAtlas @"powerup"
#define kHealerTexture @"healthPowerup"
#define kShieldTexture @"shieldPowerup"
#define kDoubleFireTexture @"projectile2Powerup"
#define kTripleFireTexture @"projectile3Powerup"
#define kQuadrupleSpinFireTexture @"projectile4Powerup"
#define kPursueTexture @"aimPowerup"
#define kConfuseTexture @"shockPowerup"
#define kDestructionTexture @"explosionPowerup"

@implementation Powerup

- (id)initAtPosition:(CGPoint)position withType:(PowerupType)type{
    // MODIFIES: self
    // EFFECTS: Init method for the power-ups    
    
    self = [super init];
    
    if (self){
        self.powerupType = type;
        self.name = kSpriteName;
        self.position = position;
        self.zPosition = -1;
        self.texture = [self determineTexture];
        self.size = CGSizeMake(kRadius * 2, kRadius * 2);
        
        [self configurePhysicsBody];
    }
    
    return self;
}

+ (Powerup*)powerupAtPosition:(CGPoint)position withType:(PowerupType)type{
    // MODIFIES: self
    // EFFECTS: Factory method for power-up. It will create a power-up at a specific position and type

    return [[Powerup alloc]initAtPosition:position withType:type];
}

- (SKTexture*)determineTexture{
    // EFFECTS: Determine power-up texture
    // RETURNS: Texture of the power-up
    
    switch (_powerupType) {
        case kHealerPowerup:
            return sHealerTexture;
            break;
        case kShieldPowerup:
            return sShieldTexture;
            break;
        case kDoubleFirePowerup:
            return sDoubleFireTexture;
            break;
        case kTripleFirePowerup:
            return sTripleFireTexture;
            break;
        case kQuadrupleFirePowerup:
            return sQuadrupleSpinFireTexture;
            break;
        case kPursuePowerup:
            return sPursueTexture;
            break;
        case kConfusePowerup:
            return sConfuseTexture;
            break;
        case kDestructionPowerup:
            return sDestructionTexture;
            break;
        default:
            break;
    }
    return nil;
}

- (void)configurePhysicsBody{
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the power-up when it is first initialized

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kRadius];
    
    CGFloat angle = -(arc4random() % 91 + 90.0) / 180.0 * acos(-1.0);
    self.physicsBody.velocity = CGVectorMake(kSpeed * cos(angle), kSpeed * sin(angle));

    self.physicsBody.restitution = 1;
    self.physicsBody.friction = 0;
    self.physicsBody.linearDamping = 0;
    self.physicsBody.angularDamping = 0;
    self.physicsBody.allowsRotation = NO;
    
    self.physicsBody.categoryBitMask = kPowerup;
    self.physicsBody.collisionBitMask = kWallLeft | kWallRight;
    self.physicsBody.contactTestBitMask = kPlayerJet;
}

- (void)collidedWith:(SKPhysicsBody*)other{
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this power-up's physic body with another game object's one

    if (other.categoryBitMask & kPlayerJet){
        [self removeFromParent];
    }
}

#pragma mark - Duration amount for power-ups

+ (void) updatePowerups{
    // MODIFIES: Strengths of different types of power-up
    // EFFECTS: Update the strenghts for power-ups
    
    GameUpgrade *currentUpgradeData = [GameUpgrade loadUpgradeData];
    sReviveStock = currentUpgradeData.reviveStock;
    sHealAmount = 300 + currentUpgradeData.healAmountRate * 50;
    sShieldDuration = 10 + currentUpgradeData.shieldDurationRate * 2;
    sDoubleFireDuration = 15 + currentUpgradeData.doubleFireDurationRate * 3;
    sTripleFireDuration = 15 + currentUpgradeData.tripleFireDurationRate * 3;
    sQuadrupleFireDuration = 15 + currentUpgradeData.quadrupleFireDurationRate * 3;
    sPursueDuration = 10 + currentUpgradeData.pursueFireDurationRate * 3;
}

static NSInteger sReviveStock = 0;
+ (NSInteger) reviveStock{
    // EFFECTS: Get the remaining available times for revival
    
    return sReviveStock;
}

+ (void) updateReviveStock:(NSInteger)remainingTimes{
    // MODIFIES: remaining time of revival stock
    // EFFECTS: Update the remaining times for revival

    sReviveStock = remainingTimes;
    GameUpgrade *currentGameUpgrade = [GameUpgrade loadUpgradeData];
    currentGameUpgrade.reviveStock = remainingTimes;
    [GameUpgrade updateUpgradeData:currentGameUpgrade];
}

static CGFloat sHealAmount = 0;
+ (CGFloat) healAmount{
    // EFFECTS: Get the heal amount for each healer power-up
    
    return sHealAmount;
}

static CGFloat sShieldDuration = 0;
+ (CGFloat) shieldDuration{
    // EFFECTS: Get the shield duration for each shield power-up
    
    return sShieldDuration;
}

static CGFloat sDoubleFireDuration = 0;
+ (CGFloat) doubleFireDuration{
    // EFFECTS: Get the duration for double fire
    
    return sDoubleFireDuration;
}

static CGFloat sTripleFireDuration = 0;
+ (CGFloat) tripleFireDuration{
    // EFFECTS: Get the duration for double fire
    
    return sTripleFireDuration;
}

static CGFloat sQuadrupleFireDuration = 0;
+ (CGFloat) quadrupleFireDuration{
    // EFFECTS: Get the duration for quadruple fire
    
    return sQuadrupleFireDuration;
}

static CGFloat sPursueDuration = 0;
+ (CGFloat) pursueDuration{
    // EFFECTS: Get the duration for pursue fire
    
    return sPursueDuration;
}

#pragma mark - Load Assets

+ (void)loadSharedAssets{
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:kPowerupAtlas];
        sHealerTexture = [atlas textureNamed:kHealerTexture];
        sShieldTexture = [atlas textureNamed:kShieldTexture];
        sDoubleFireTexture = [atlas textureNamed:kDoubleFireTexture];
        sTripleFireTexture = [atlas textureNamed:kTripleFireTexture];
        sQuadrupleSpinFireTexture = [atlas textureNamed:kQuadrupleSpinFireTexture];
        sPursueTexture = [atlas textureNamed:kPursueTexture];
        sConfuseTexture = [atlas textureNamed:kConfuseTexture];
        sDestructionTexture = [atlas textureNamed:kDestructionTexture];
     });
}

static SKTexture* sHealerTexture = nil;
+ (SKTexture*)healerTexture{
    // EFFECTS: Get texture for healer power-up
    
    return sHealerTexture;
}

static SKTexture* sShieldTexture = nil;
+ (SKTexture*)shieldTexture{
    // EFFECTS: Get texture for shield power-up
    
    return sShieldTexture;
}

static SKTexture* sDoubleFireTexture = nil;
+ (SKTexture*)doubleFireTexture{
    // EFFECTS: Get texture for double fire power-up
    
    return sDoubleFireTexture;
}

static SKTexture* sTripleFireTexture = nil;
+ (SKTexture*)tripleFireTexture{
    // EFFECTS: Get texture for triple fire power-up
    
    return sTripleFireTexture;
}

static SKTexture* sQuadrupleSpinFireTexture = nil;
+ (SKTexture*)quadrupleSpinFireTexture{
    // EFFECTS: Get texture for quadruple spin fire power-up
    
    return sQuadrupleSpinFireTexture;
}

static SKTexture* sPursueTexture = nil;
+ (SKTexture*)pursueTexture{
    // EFFECTS: Get texture for pursue power-up
    
    return sPursueTexture;
}

static SKTexture* sConfuseTexture = nil;
+ (SKTexture*)confuseTexture{
    // EFFECTS: Get texture for confuse power-up
    
    return sConfuseTexture;
}

static SKTexture* sDestructionTexture = nil;
+ (SKTexture*)destructionTexture{
    // EFFECTS: Get texture for destruction power-up
    
    return sDestructionTexture;
}

@end
