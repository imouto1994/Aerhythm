#import "NinjaEnemy.h"
#import "Vector2D.h"
#import "PlayScene.h"

#define kFiringSpeed 3.25
#define kHealth 500.0f
#define kHorizontalVelocity 400.0f
#define kSlowFactor 3.0f
#define kNumberNeededFrozenBullet 15
#define kNumberNeededWindBullet 20
#define kFireDamage 2
#define kRadius 72

#define kScore 40

@interface NinjaEnemy()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation NinjaEnemy

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
        self.bulletType = kNinjaEnemyBullet;
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
        CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                               fromNode:self];
        CGPoint enemyWorldPoint = [[self gameObjectScene] convertPoint:self.position
                                                              fromNode:self.parent];
        
        CGFloat aboveOrBelow = -1;
        if (playerWorldPoint.y < enemyWorldPoint.y) {
            aboveOrBelow = 1;
        }
        
        // Behavior of ninja
        CGVector velocity = [Bullet getDefaultVelocity:self.bulletType];
        if (hasHint) {
            // Have player position as a hint
            Vector2D * fireDirectionVector = [[Vector2D vectorFromPoint:enemyWorldPoint
                                                                toPoint:playerWorldPoint] normalize];
            CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
            velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
        }
        
        CGFloat firingDistanceOffset = self.radius / 2 + [Bullet getDefaultRadiusSize:self.bulletType];
        
        Vector2D * unitDirection = [[Vector2D vectorFromCGVector:velocity] normalize];
        
        CGPoint firingPosition = [[unitDirection scalarMultiply:firingDistanceOffset]
                                  applyVectorTranslationToPoint:self.position];
        Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                  andBulletType:self.bulletType
                                                    andVelocity:velocity
                                                     fromOrigin:kEnemyJet];
        [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        
        // Add 1 more random ninja bullet
        // Generate rotating angles randomly between 20.0 and 50.0 degree
        CGFloat rotateAngle = arc4random() % 30 + 20.0;
        // Determine whether the rotation should be clockwise or anticlockwise
        CGFloat clockwise = 1.0;
        CGFloat dotProductHorizon = [unitDirection dotProduct:[Vector2D vectorWithX:1 andY:0]];
        if ((dotProductHorizon > 0 && unitDirection.y > 0) ||
            (dotProductHorizon < 0 && unitDirection.y < 0)) {
            clockwise = -1.0;
        }
        rotateAngle *= clockwise;
        
        Vector2D * newUnitDirection = [unitDirection rotateWithAngle:rotateAngle];
        Vector2D * newVelocity = [[Vector2D vectorFromCGVector:velocity]
                                  rotateWithAngle:rotateAngle];
        firingPosition = [[newUnitDirection scalarMultiply:firingDistanceOffset]
                          applyVectorTranslationToPoint:self.position];
        bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                         andBulletType:self.bulletType
                                           andVelocity:[newVelocity toCGVector]
                                            fromOrigin:kEnemyJet];
        [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        
        self.fireCounter = kDefaultFireCounter;
    }
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    sDefaultTexture = [[self sTextureAtlas] textureNamed:@"enemy3"];
    sDeadTexture = [[self sTextureAtlas] textureNamed:@"enemy3-dead"];
    sFrozenTexture = [[self sTextureAtlas] textureNamed:@"enemy3-frozen"];
    
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
