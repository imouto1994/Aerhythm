#import "BossEnemy.h"
#import "PlayScene.h"

#define kPowerupGenerationSpeed 10
#define kDefaultPowerupGenerationCounter 500
#define kIncreaseManaRatio 25

@implementation BossEnemy {
    // The counter for generating power-ups
    float powerupGenerationCounter;
}

- (void)initialize {
    // MODIFIES: self
    // EFFECTS: Setup the game object when it is first initialized
    
    [super initialize];
    powerupGenerationCounter = kDefaultPowerupGenerationCounter;
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the game object when it is first initialized
    
    [super configurePhysicsBody];
    self.physicsBody.categoryBitMask = kBossJet;
    self.physicsBody.collisionBitMask = kPlayerJet | kWallLeft | kWallRight;
}

- (void)update {
    // MODIFIES: self
    // EFFECTS: Update the state of the game object, this method is called for each game loop
    
    [super update];
    [self handlePowerupGeneration];
}

- (BOOL) applyDamage:(CGFloat)damage{
    [self.gameObjectScene increaseManaBy:damage / kIncreaseManaRatio];
    return [super applyDamage:damage];
}

- (void)handlePowerupGeneration {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the update of generating of power-ups
    
    powerupGenerationCounter -= kPowerupGenerationSpeed;
    if (powerupGenerationCounter > 0) {
        return;
    }
    
    NSArray* availableTypes = @[[NSNumber numberWithUnsignedInteger:kHealerPowerup],
                                [NSNumber numberWithUnsignedInteger:kShieldPowerup],
                                [NSNumber numberWithUnsignedInteger:kDoubleFirePowerup],
                                [NSNumber numberWithUnsignedInteger:kTripleFirePowerup],
                                [NSNumber numberWithUnsignedInteger:kQuadrupleFirePowerup]];
    
    [self generatePowerupsOfTypes:availableTypes];
    powerupGenerationCounter = kDefaultPowerupGenerationCounter;
}

- (void)performDeath {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handling method when the jet is dead
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    self.health = 0.0f;
    [self setCurrentState:STATE_DEATH];
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    
    [self updateGamescore];
    [[self gameObjectScene] playerDidKillBoss];
    
    SKAction * deadthEffectAction = [self deadthEffectAction];
    
    SKAction * fadeOutMusic = [SKAction runBlock:^{
        [self.gameObjectScene.musicPlayer fadeOut];
    }];
    
    SKAction * notifyAction = [SKAction runBlock:^{
        [self.gameObjectScene.delegate gameDidEnd];
    }];
    SKAction * deadthAction = [SKAction sequence:@[deadthEffectAction, notifyAction]];
    
    SKAction * groupAction = [SKAction group:@[fadeOutMusic, deadthAction]];
    [self runAction:groupAction];
}

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDeadthEffectAction = [SKAction fadeOutWithDuration:4.0];
    });
}

// Action to create effect when the boss is dead
static SKAction * sDeadthEffectAction = nil;
- (SKAction *)deadthEffectAction {
    return sDeadthEffectAction;
}

@end
