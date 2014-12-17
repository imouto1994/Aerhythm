#import "IceEnemy.h"
#import "Vector2D.h"
#import "PlayScene.h"

#define kFiringSpeed 2.75
#define kHealth 450.0f
#define kHorizontalVelocity 350.0f
#define kSlowFactor 3.0f
#define kNumberNeededFrozenBullet 1000
#define kNumberNeededWindBullet 17
#define kFireDamage 2
#define kRadius 56

#define kScore 50

@interface IceEnemy()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation IceEnemy

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
        self.bulletType = kIceEnemyBullet;
        self.firingSpeed = kFiringSpeed;
        self.originalFiringSpeed = kFiringSpeed;
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
        CGPoint firingPosition = CGPointMake(self.position.x, self.position.y - self.radius);
        
        CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                               fromNode:self];
        
        CGFloat distanceOffset = 20;
        CGFloat lineOffset = 35;
        
        firingPosition.x -= lineOffset;
        for (NSUInteger bulletLine = 0; bulletLine < 2; bulletLine++) {
            firingPosition.y = self.position.y - self.radius;
            
            for (NSUInteger i = 0; i < 2; i++) {
                CGPoint fireWorldPoint = [[self gameObjectScene] convertPoint:firingPosition
                                                                 fromNode:self.parent];
                if (playerWorldPoint.y > fireWorldPoint.y) {
                    self.fireCounter = kDefaultFireCounter;
                    return;
                }
            
                CGVector velocity = [Bullet getDefaultVelocity:self.bulletType];
                if (hasHint) {
                    // Have player position as a hint
                    Vector2D * fireDirectionVector = [[Vector2D vectorFromPoint:fireWorldPoint
                                                                    toPoint:playerWorldPoint] normalize];
                    CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
                    velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
                }
            
                Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                          andBulletType:self.bulletType
                                                            andVelocity:velocity
                                                             fromOrigin:kEnemyJet];
            
                [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
            
                firingPosition.y = firingPosition.y - [Bullet getDefaultRadiusSize:self.bulletType]
                                   - distanceOffset;
            }
            
            firingPosition.x += [Bullet getDefaultRadiusSize:self.bulletType] + lineOffset;
        }
        
        
            self.fireCounter = kDefaultFireCounter;
    }
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    sDefaultTexture = [[self sTextureAtlas] textureNamed:@"enemy4"];
    sDeadTexture = [[self sTextureAtlas] textureNamed:@"enemy4-dead"];

}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sDefaultTexture = nil;
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

+ (float)scoreGain {
    return kScore;
}

@end
