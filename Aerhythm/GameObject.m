#import "GameObject.h"
#import "Vector2D.h"
#import "PlayScene.h"

@implementation GameObject

-(id) initAtPosition:(CGPoint)position{
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position
    
    self = [super init];
    if(self){
        self.position = position;
    }
    return self;
}

- (void)update {
    // MODIFIES: self
    // EFFECTS: Update the state of the game object, this method is called for each game loop
    
}

- (void)initialize {
    // MODIFIES: self
    // EFFECTS: Setup the game object when it is first initialized
    
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the game object when it is first initialized
    
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this object's physic body with another object's one
    
}

- (void)collidedWithWall:(WallType)wall{
    // REQUIRE: self != nil
    // EFFECTS: Handle when the enemy jet is colliding with the wall
}

- (void)addToScene:(PlayScene *)scene {
    // EFFECTS: Add this node to an assigned scene
    
    [scene addChild:self];
}

- (void)removeFromScene {
    // EFFECTS: Get the reference to the current scene that this game object is in
    
}

- (PlayScene *)gameObjectScene {
    // EFFECTS: Get the reference to the current scene that this game object is in
    
    PlayScene *scene = (id)[self scene];
    
    if ([scene isKindOfClass:[PlayScene class]]) {
        return scene;
    }
    
    return nil;
}

- (void)removeEmitter:(SKEmitterNode*)emitter{
    for(SKNode *childNode in [self children]){
        if([childNode isKindOfClass:[SKEmitterNode class]]){
            SKEmitterNode *childEmitter = (SKEmitterNode *)childNode;
            if(childEmitter.particleTexture == emitter.particleTexture){
                [childEmitter removeFromParent];
            }
        }
    }
}

- (void)removeChildWithTexture:(SKTexture*)texture{
    for(SKNode *childNode in [self children]){
        if([childNode isKindOfClass:[SKSpriteNode class]]){
            SKSpriteNode *childEmitter = (SKSpriteNode *)childNode;
            if(childEmitter.texture == texture){
                [childEmitter removeFromParent];
            }
        }
    }
}

+ (void)loadSharedAssets{
    // EFFECTS: Load all the shared assets that any instances of this class will use
}

+ (void)releaseSharedAssets
{
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
}

@end
