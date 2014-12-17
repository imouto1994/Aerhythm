#import "GameJet.h"
#import "Utilities.h"

@implementation GameJet

- (id)initAtPosition:(CGPoint)position {
    // MODIFIES: self
    // EFFECTS: Override the jet sprite node at an assigned position
    
    self = [super init];
    
    return self;
}

- (void)setCurrentState:(State)currentState {
    // MODIFIES: self.currentState
    // EFFECTS: Override the SETTER method for the current state
    // Set the property |hasStateChanged| to YES to notify to change view representation
    
    if(_currentState != STATE_DEATH){
    _currentState = currentState;
    _hasStateChanged = YES;
    }
}

- (void)fire {
    // REQUIRES: self != nil
    // EFFECTS: Handling method when the jet fires the bullets
}

- (void)performDeath {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handling method when the jet is dead

    _health = 0.0f;
    [self setCurrentState:STATE_DEATH];
}

- (BOOL)applyDamage:(CGFloat)damage {
    // MODIFIES: self.health
    // EFFECTS: Apply an assigned damage to the jet
    
    if(_health > damage){
        _health -= damage;
    } else {
        [self performDeath];
    }
    return true;
}

#pragma mark - Load Shared Assets
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sFireEmitter = [Utilities createEmitterNodeWithEmitterNamed:@"Fire"];
        sSlowEmitter = [Utilities createEmitterNodeWithEmitterNamed:@"ColdSmoke"];
        UIImage *shockIcon = [Utilities loadImageWithName:@"shockIcon"];
        sShockIconTexture = [SKTexture textureWithImage:shockIcon];
    });
}

static SKEmitterNode *sFireEmitter = nil;
- (SKEmitterNode *)fireEmitter {
    return sFireEmitter;
}

static SKEmitterNode *sSlowEmitter = nil;
- (SKEmitterNode *)slowEmitter {
    return sSlowEmitter;
}

static SKTexture *sShockIconTexture = nil;
- (SKTexture *) shockIconTexture {
    return sShockIconTexture;
}

@end
