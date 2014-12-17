#import "ShockEnemy.h"
#import "Vector2D.h"
#import "PlayScene.h"

#define kFiringSpeed 4.0
#define kHealth 525.0f
#define kHorizontalVelocity 300.0f
#define kSlowFactor 3.0f
#define kNumberNeededFrozenBullet 8
#define kNumberNeededWindBullet 15
#define kFireDamage 2
#define kRadius 56

#define kScore 70

@interface ShockEnemy()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation ShockEnemy

@dynamic originalFiringSpeed;

- (id)initAtPosition:(CGPoint)position {
    return [self initAtPosition:position enableFire:YES];
}

- (id)initAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire {
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position
    
    self = [super initAtPosition:position withRadius:kRadius enableFire:isEnableFire];
    
    if (self){
        self.texture = sDefaultTexture;
        self.health = kHealth;
        self.bulletType = kShockEnemyBullet;
        self.originalFiringSpeed = kFiringSpeed;
        self.firingSpeed = kFiringSpeed;
        self.physicsBody.velocity = CGVectorMake(kHorizontalVelocity, 0.0);
        self.jetSpeed = kHorizontalVelocity;
        self->slowFactor = kSlowFactor;
        self->numberNeededFrozenBullet = kNumberNeededFrozenBullet;
        self->numberNeededWindBullet = kNumberNeededWindBullet;
        self->fireDamage = kFireDamage;
    }
    return self;
}

- (CGVector)getOriginalVelocity {
    // EFFECTS: Return original velocity
    
    return CGVectorMake(kHorizontalVelocity, 0.0);
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    if (!self.isAbleToFire) {
        return;
    }
    
    self.fireCounter -= self.firingSpeed;
    if(self.fireCounter  < 0) {
        Vector2D * velocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:self.bulletType]];
        for (NSInteger i = -2; i < 3; i++) {
            CGPoint firingPosition = CGPointMake(self.position.x + i * 40, self.position.y - self.radius - 10);
            Vector2D * newVelocity = [velocity rotateWithAngle:(i * 45)];
            Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                      andBulletType:self.bulletType
                                                        andVelocity:[newVelocity toCGVector]
                                                         fromOrigin:kEnemyJet];
            [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        }
        self.fireCounter = kDefaultFireCounter;
    }
}


#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
      
    sDefaultTexture = [[self sTextureAtlas] textureNamed:@"enemy7"];
    sDeadTexture = [[self sTextureAtlas] textureNamed:@"enemy7-dead"];
    sFrozenTexture = [[self sTextureAtlas] textureNamed:@"enemy7-frozen"];
}


+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sDefaultTexture = nil;
    sFrozenTexture = nil;
}

static SKTexture *sDefaultTexture = nil;
+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Gets the shared default texture
    
    return sDefaultTexture;
}

static SKTexture *sDeadTexture = nil;
+ (SKTexture *)sDeadTexture {
    // EFFECTS: Gets the shared default texture when the jet is dying
    
    return sDeadTexture;
}

static SKTexture *sFrozenTexture = nil;

+ (SKTexture *)sFrozenTexture {
    // EFFECTS: Gets the shared default texture when the jet is frozen
    
    return sFrozenTexture;
}

+ (float)scoreGain {
    return kScore;
}

@end