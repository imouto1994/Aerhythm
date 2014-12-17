#import "PlayScene.h"
#import "Vector2D.h"
#import "PlayerJetFactory.h"
#import "EnemyJet.h"
#import "EnemyFactory.h"
#import "BossEnemy.h"
#import "EnemyBullet.h"
#import "Powerup.h"
#import "Utilities.h"
#import "SuicideEnemy.h"
#import "PlayScene+PlayerMovement.h"

@interface PlayScene () <SKPhysicsContactDelegate>

// Player jet
@property (strong, atomic, readwrite) PlayerJet * playerJet;
// Tracker for player mile ston
@property (strong, nonatomic, readwrite) SKSpriteNode *tracker;
// Bar for player's health
@property (strong, nonatomic, readwrite) SKSpriteNode *hpBar;
// Background under player's health
@property (strong, nonatomic, readwrite) SKSpriteNode *underHpBar;
// Label showing score
@property (strong, nonatomic, readwrite) SKLabelNode *scoreLabel;
// Label showing remaining revival stock
@property (strong, nonatomic, readwrite) SKLabelNode *revivalStock;
// Highest-level nod in game
@property (strong, nonatomic, readwrite) SKSpriteNode *world;
// List of layers in game world
@property (strong, nonatomic) NSMutableArray *layers;
// Flag indicator whether we should move the background for scrolling
@property (nonatomic, readwrite) BOOL moveBackgroundFlag;

@property (strong, nonatomic, readwrite) NSMutableArray * backgroundSpriteNodes;

@property (nonatomic, readwrite) void * levelMap;

@property (strong, nonatomic, readwrite) NSMutableArray * hiddenEnemyNodes;

@end

#define kTopWallOffset 200
#define kLevelMapLayoutWidth 12
#define kLevelMapLayoutHeight 16
#define kMaxWidthSingleHPBar 595
#define kOffset 1

static NSString * const kMovingEnemyActionKey = @"moveEnemyAction";

@implementation PlayScene {
    
    NSInteger totalEnemy;
    
    NSTimeInterval lastTime;
    
    BOOL foundBoss;
}

-(id)initWithSize:(CGSize)size
{
    // MODIFIES: self
    // EFFECTS: Override the initialize method
    
    self = [super initWithSize:size];
    if (self) {
        foundBoss = false;
        self.moveBackgroundFlag = YES;
        if ([self.class sNumBackgroundPerLevel] < 2) {
            self.moveBackgroundFlag = NO;
        }
        
        // Build level map
        self.levelMap = [Utilities createDataMap:
                         [NSString stringWithFormat:@"map-%lu.png", (unsigned long)sLevelId]];
        
        /* Setup world scene */
        _world = [[SKSpriteNode alloc] init];
        [_world setName:@"world"];
        _layers = [NSMutableArray arrayWithCapacity:kLayerCount];
        for(int i = 0; i < kLayerCount; i++){
            SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = i - kLayerCount;
            if(i == kHUDLayer){
                layer.zPosition += kLayerCount;
            }
            [_world addChild:layer];
            [_layers addObject:layer];
        }
        [self addChild:_world];
        self.world.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        totalEnemy = 0;
    }
    return self;
}

- (void)dealloc{
    free(self.levelMap);
    self.levelMap = NULL;
}

-(void)addNode:(SKNode *)node atWorldLayer:(WorldLayer)layer
{
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Add a node at an assigned layer
    
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (SKNode *)getWorldLayer:(WorldLayer)layer
{
    // REQUIRES: self != nil
    // EFFECTS: Gets the specified layer node
    return self.layers[layer];
}

-(void)didMoveToView:(SKView *)view
{
    // REQUIRES: self != nil
    // EFFECTS: Override this method from superclass, add a pan gesture recognizer
    
    _gameAchievement = [[GameAchievement alloc] initWithTotalEnemy:totalEnemy andOriginalHealth:_playerJet.health];
    [super didMoveToView:view];
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
}

#pragma mark - Load Scene Assets
-(void)loadSceneAssetsWithCompletionHandler:(AssetLoadCompletionHandler)handler {
    // EFFECTS: Load all assets with an assigned completion block
    
    [Powerup updatePowerups];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self loadSceneAssets];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}

-(void)loadSceneAssets{
    // EFFECTS: Load all assets
    
    // Updating duration for power up
    [PlayerJet loadSharedAssets];
    [EnemyBullet loadSharedAssets];

    if(sNeedsLevelReloaded || sNeedsModelReloaded){
        // Loading assets for bullet
        [Bullet loadSharedAssets];
        
        [self updateProgress:3];
         if(sNeedsLevelReloaded){
            NSArray *enemyList = [Constant enemyList:[PlayScene sLevelId] - 1];
            // Loading assets for enemy jets
            [EnemyJet loadSharedAssets];
            [BossEnemy loadSharedAssets];
            [EnemyFactory loadSharedAssetsForEnemyTypes:enemyList];
        };
        
        [self updateProgress:4];
        
        // Loading assets for powerup
        [Powerup loadSharedAssets];
        [self updateProgress:5];
        if(sNeedsModelReloaded){
            // Loading assets for player jet
            [PlayerJetFactory loadSharedAssets];
            // Loading assets for bullet
            [PlayerBullet loadSharedAssets];
        }
        // Loading background
        [PlayScene loadBackground];
        [LightningBolt loadSharedAssets];
        
        [self updateProgress:6];
        
        sNeedsLevelReloaded = NO;
        sNeedsModelReloaded = NO;
    } else {
        [self updateProgress:3];
        [self updateProgress:4];
        [self updateProgress:5];
        [self updateProgress:6];
    }
}

+ (void)releaseLevelSharedAssets
{
    // EFFECTS: Releases all unncessary shared assets after game ends
    
    sBackgroundTextures = nil;
    [EnemyFactory releaseSharedAssets];
    
    sNeedsLevelReloaded = YES;
}

+ (void)releaseBackgroundAssets
{
    // EFFECTS: Releases all background image assets
    
    sBackgroundTextures = nil;
}

+ (void)releaseModelSharedAssets{
    [PlayerJetFactory releaseSharedAssets];
    [PlayerBullet releaseSharedAssets];
    
    sNeedsModelReloaded = YES;
}

-(void) updateProgress:(NSInteger) progress{
    // EFFECTS: Notify the delegate to update the current progress of loading assets
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate showCurrentLoadingAssetProgressAt:progress];
    });
}

+ (void)loadBackground
{
    // EFFECTS: Loads all background images for the current level
    
    sBackgroundTextures = [NSMutableArray arrayWithCapacity:sNumBackgroundPerLevel];
    
    for (NSUInteger i = 0; i < sNumBackgroundPerLevel; i++) {
        NSString * imageFileName = [NSString stringWithFormat:@"level%lu-%lu", (unsigned long)sLevelId,
                                    (unsigned long)i + 1];
        
        UIImage * image = [UIImage imageWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"]];
        
        SKTexture * texture = [SKTexture textureWithImage:image];
        
        [sBackgroundTextures addObject:texture];
    }
}

#pragma mark - World Building
- (void)buildGameWorld
{
    // Initialize physics world properties
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    // Add background
    [self addBackground];
    [self addWalls];
    
    // Add enemies
    [self addEnemies];
    
    // Add player jet
    self.playerJet = [PlayerJetFactory createPlayerJetAtPosition:CGPointMake(0, 0)];
    [self addNode:self.playerJet atWorldLayer:kPlayerLayer];
    self.gameScore = 0.0;
    
    // Build HUD
    [self buildHUD];
}

- (void)addBackground{
    // EFFECTS: Adds the loaded background images / textures to background layer
    
    if (self.backgroundSpriteNodes) {
        [self.backgroundSpriteNodes removeAllObjects];
    } else {
        self.backgroundSpriteNodes = [[NSMutableArray alloc] init];
    }
    
    for (NSUInteger i = 0; i < sNumBackgroundPerLevel; i++) {
        SKTexture * texture = [[self backgroundTextures] objectAtIndex:i];
        SKSpriteNode * backgroundNode = [[SKSpriteNode alloc] initWithTexture:texture];
        backgroundNode.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        CGPoint position = CGPointZero;
        if (i > 0) {
            SKSpriteNode * prevBackground = (SKSpriteNode *)self.backgroundSpriteNodes[i - 1];
            position = CGPointMake(prevBackground.position.x,
                                   prevBackground.position.y + prevBackground.frame.size.height);
        }
        backgroundNode.position = position;
        backgroundNode.zPosition = -1.0f;
        backgroundNode.blendMode = SKBlendModeReplace;
        [self.backgroundSpriteNodes addObject:backgroundNode];
        
        [self addNode:backgroundNode atWorldLayer:kBackgroundLayer];
    }
}

- (void)addWalls {
    // REQUIRES: self != nil
    // EFFECTS: Adds wall objects to game world
    
    CGPoint bottomLeftCorner = CGPointMake(0, 0);
    bottomLeftCorner = [self.layers[kBackgroundLayer] convertPoint:bottomLeftCorner fromNode:self];
    
    CGPoint bottomRightCorner = CGPointMake(self.size.width, 0);
    bottomRightCorner = [self.layers[kBackgroundLayer] convertPoint:bottomRightCorner fromNode:self];
    
    CGPoint topLeftCorner = CGPointMake(0, self.size.height);
    topLeftCorner = [self.layers[kBackgroundLayer] convertPoint:topLeftCorner fromNode:self];
    CGPoint topWallLeftCorner = CGPointMake(topLeftCorner.x, 2 * topLeftCorner.y);
    
    CGPoint topRightCorner = CGPointMake(self.size.width, self.size.height);
    topRightCorner = [self.layers[kBackgroundLayer] convertPoint:topRightCorner fromNode:self];
    CGPoint topWallRightCorner = CGPointMake(topRightCorner.x, topRightCorner.y * 2);
    
    // Left Wall
    SKNode * leftWall = [[SKNode alloc] init];
    leftWall.name = @"wall";
    leftWall.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeftCorner
                                                        toPoint:topWallLeftCorner];
    leftWall.physicsBody.categoryBitMask = kWallLeft;
    leftWall.physicsBody.collisionBitMask = 0;
    leftWall.physicsBody.contactTestBitMask = kEnemyBullet | kPlayerBullet;
    
    // Right Wall
    SKNode * rightWall = [[SKNode alloc] init];
    rightWall.name = @"wall";
    rightWall.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomRightCorner
                                                         toPoint:topWallRightCorner];
    rightWall.physicsBody.categoryBitMask = kWallRight;
    rightWall.physicsBody.collisionBitMask = 0;
    rightWall.physicsBody.contactTestBitMask = kEnemyBullet | kPlayerBullet;
    
    [self addNode:leftWall atWorldLayer:kBackgroundLayer];
    [self addNode:rightWall atWorldLayer:kBackgroundLayer];
}

- (void)addEnemies {
    // EFFECTS:
    NSUInteger width = kLevelMapLayoutWidth;
    NSUInteger height = kLevelMapLayoutHeight * [PlayScene sNumBackgroundPerLevel];
    
    self.hiddenEnemyNodes = [[NSMutableArray alloc] init];
    
    SKNode * enemyLayer = self.layers[kEnemyLayer];
    
    for (NSUInteger y = 0; y < height; y++) {
        for (NSUInteger x = 0; x < width; x++) {
            CGPoint levelLayoutPoint = CGPointMake(x, y);
            EnemyType enemyType = [self determineEnemyTypeAtLocation:levelLayoutPoint];
            
            if (enemyType != kNoEnemy) {
                CGPoint worldPoint = [self convertLevelLayoutMapPointToWorldPoint:levelLayoutPoint];
                CGPoint pointInEnemyLayer = [enemyLayer convertPoint:worldPoint fromNode:self];
                // Create dummy node
                SKSpriteNode * enemyNode = [self createDummyEnemyNodeAtPosition:pointInEnemyLayer
                                                                       withType:enemyType];
                
                [self addNode:enemyNode atWorldLayer:kEnemyLayer];
                [self.hiddenEnemyNodes addObject:enemyNode];
                
                totalEnemy++;
            }
        }
    }
    
    [self makeEnemyAppear];
}

- (void)makeEnemyAppear
{
    SKNode * enemyLayerNode = self.layers[kEnemyLayer];
    
    while ([self.hiddenEnemyNodes count] > 0) {
        SKSpriteNode * hiddenEnemy = [self.hiddenEnemyNodes objectAtIndex:0];
        
        CGPoint worldPoint = [self convertPoint:hiddenEnemy.position fromNode:enemyLayerNode];
        
        CGFloat y = worldPoint.y;
        EnemyType enemyType = [Constant getEnemyTypeFromName:hiddenEnemy.name];
        CGFloat radius = [EnemyFactory getRadiusOfEnemyType:enemyType];
        
        if (y < self.frame.size.height - kHeightHPBar + radius) {
            // This enemy is going to appear soon
            EnemyJet * enemyNode = [EnemyFactory createEnemyJetWithType:enemyType
                                                          andAtPosition:hiddenEnemy.position];
            [self addNode:enemyNode atWorldLayer:kEnemyLayer];
            
            // Check if boss appearing
            if (enemyNode.physicsBody.categoryBitMask == kBossJet) {
                foundBoss = true;
                [self updateHpBarWhenBossAppears];
            }
            
            [hiddenEnemy removeFromParent];
            [self.hiddenEnemyNodes removeObjectAtIndex:0];
            
            // Set some enemy's properties
            enemyNode.isAbleToFire = NO;
            enemyNode.isMovingToScene = YES;
            enemyNode.isImmuneToBullet = YES;
        } else {
            // Hidden enemy list are sorted in increasing order of y-coordinate
            break;
        }
    }
}

- (SKSpriteNode *)createDummyEnemyNodeAtPosition:(CGPoint)location withType:(EnemyType)enemyType;
{
    SKSpriteNode * enemyNode = [[SKSpriteNode alloc] init];
    enemyNode.position = location;
    enemyNode.name = [Constant getNameOfEnemyWithType:enemyType];
    
    return enemyNode;
}

- (void)killAllEnemiesExceptBoss {
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
        EnemyJet * enemyNode = (EnemyJet *)node;
        if (!(enemyNode.physicsBody.categoryBitMask & kBossJet)){
            [enemyNode performDeathWithEmitter];
        }
    }];
}
- (void) performSpecialMove{
    [self.playerJet enableSpecialMove];
}

- (LightningBolt*)addLightningBoltAimedAtPlayerWithLifetime:(CGFloat)lifetime
                                           andLineDrawDelay:(CGFloat)lineDrawDelay
                                               andThickness:(CGFloat)thickness{
    
    CGFloat randomStartX = arc4random() % (int) self.frame.size.width;
    CGPoint startPoint = CGPointMake(randomStartX, self.frame.size.height);
    CGPoint endPoint = [self convertPoint:self.playerJet.position fromNode:self.layers[kPlayerLayer]];
    
    LightningBolt* lightningBolt = [LightningBolt lightningWithStartPoint:startPoint
                                                                 endPoint:endPoint
                                                                 lifetime:lifetime
                                                            lineDrawDelay:lineDrawDelay
                                                                thickness:thickness];
    [self addChild:lightningBolt];
    
    return lightningBolt;
}

#pragma mark - HUD and Scores
- (void)buildHUD
{
    [self addHPBar];
    [self addScore];
    [self addTrackbar];
    [self addRevivalDisplay];
}

- (void)updateHpBarWhenBossAppears
{
    self.underHpBar.texture = [SKTexture textureWithImageNamed:@"hpBar-background-boss"];
}

-(void) addScore{
    _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura (Light)"];
    [_scoreLabel setFontSize:30];
    [_scoreLabel setText:@"0"];
    [_scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    _scoreLabel.position = CGPointMake(250, 512 - 35);
    [self addNode:_scoreLabel atWorldLayer:kHUDLayer];
    _scoreLabel.zPosition++;
}

- (void)addTrackbar {
    SKSpriteNode *trackBar = [[SKSpriteNode alloc] init];
    UIImage *trackBarImage = [Utilities loadImageWithName:@"trackBar"];
    SKTexture *trackBarTexture = [SKTexture textureWithImage:trackBarImage];
    trackBar.texture = trackBarTexture;
    trackBar.size = CGSizeMake(100, 315);
    trackBar.position = CGPointMake(-334, -270);
    [self addNode:trackBar atWorldLayer:kHUDLayer];
    
    _tracker = [[SKSpriteNode alloc] init];
    UIImage *trackerImage = [Utilities loadImageWithName:@"tracker"];
    SKTexture *trackerTexture = [SKTexture textureWithImage:trackerImage];
    _tracker.texture = trackerTexture;
    _tracker.size = CGSizeMake(20, 20);
    _tracker.position = CGPointMake(-335, -410);
    [self addNode:_tracker atWorldLayer:kHUDLayer];
}

- (void)addRevivalDisplay {
    SKSpriteNode *revivalIcon = [[SKSpriteNode alloc] init];
    UIImage *revivalImage = [Utilities loadImageWithName:@"revivePowerup"];
    SKTexture *revivalTexture = [SKTexture textureWithImage:revivalImage];
    revivalIcon.texture = revivalTexture;
    revivalIcon.size = CGSizeMake(75, 75);
    revivalIcon.position = CGPointMake(335, -375);
    [self addNode:revivalIcon atWorldLayer:kHUDLayer];
    
    _revivalStock = [[SKLabelNode alloc] initWithFontNamed:@"Futura (Light)"];
    [_revivalStock setFontSize:30];
    [_revivalStock setText:[NSString stringWithFormat:@"%ld", (long)[Powerup reviveStock]]];
    [_revivalStock setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    _revivalStock.position = CGPointMake(325, -325);
    [self addNode:_revivalStock atWorldLayer:kHUDLayer];
    _revivalStock.zPosition++;

}

- (void)updateHUDForPlayer
{
    // Update HP Bar
    if (!foundBoss) {
        // Before fighting with boss
        
        CGFloat health = self.playerJet.health;
        CGFloat maxHealth = self.playerJet.maxHealth;
        CGFloat newWidth = (health / maxHealth) * kMaxWidthSingleHPBar;
        self.hpBar.size = CGSizeMake(newWidth, kHeightHPBar);
        
    } else {
        // During fighting with boss
        CGFloat playerHealthRatio = self.playerJet.health / self.playerJet.maxHealth;
        __block CGFloat bossHealthRatio = 0.0;
        
        [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
            EnemyJet * enemyNode = (EnemyJet *)node;
            if (enemyNode.physicsBody.categoryBitMask == kBossJet) {
                bossHealthRatio = enemyNode.health / enemyNode.maxHealth;
            }
        }];
        
        CGFloat newWidth = playerHealthRatio / (playerHealthRatio + bossHealthRatio) * kMaxWidthSingleHPBar;
        self.hpBar.size = CGSizeMake(newWidth, kHeightHPBar);
    }
    
    // Update mana
    CGFloat currentMana = self.playerJet.currentMana;
    CGFloat maxMana = self.playerJet.maxMana;
    if(currentMana >= maxMana){
        currentMana = maxMana;
        [self.delegate updateManaView:10.0];
    } else {
        NSInteger counter = (int) (currentMana * 10.0 / maxMana);
        [self.delegate updateManaView:counter];
    }
    
    // Update special
     [_revivalStock setText:[NSString stringWithFormat:@"%ld", (long)[Powerup reviveStock]]];
    
    // Update tracker
    SKNode *enemyLayer = self.layers[kEnemyLayer];
    
    float trackerDistanceFromOrigin = 0;
    if([PlayScene sNumBackgroundPerLevel] != 1){
        trackerDistanceFromOrigin = 285 * enemyLayer.position.y / (1024 * ([PlayScene sNumBackgroundPerLevel] - 1));
    }
    self.tracker.position = CGPointMake(self.tracker.position.x, -410 - trackerDistanceFromOrigin);
    
    // Update score
    [self.scoreLabel setText:[NSString stringWithFormat:@"%.0f", self.gameScore]];
}

- (void)addHPBar {
    SKSpriteNode *hpBorder = [[SKSpriteNode alloc] init];
    UIImage *borderImage = [Utilities loadImageWithName:@"hpBar"];
    SKTexture *texture = [SKTexture textureWithImage:borderImage];
    hpBorder.texture = texture;
    hpBorder.position = CGPointMake(0, 512 - 29);
    hpBorder.size = CGSizeMake(768, 58);
    [self addNode:hpBorder atWorldLayer:kHUDLayer];
    
    self.hpBar = [[SKSpriteNode alloc] init];
    self.hpBar.texture = [SKTexture textureWithImageNamed:@"hpBar-foreground"];
    self.hpBar.size = CGSizeMake(kMaxWidthSingleHPBar, kHeightHPBar);
    self.hpBar.anchorPoint = CGPointMake(0, 0);
    self.hpBar.position = CGPointMake(-350, -20);
    [hpBorder addChild:self.hpBar];
    self.hpBar.zPosition = hpBorder.zPosition - 1;
    
    self.underHpBar = [[SKSpriteNode alloc] init];
    self.underHpBar.texture = [SKTexture textureWithImageNamed:@"hpBar-background"];
    self.underHpBar.size = CGSizeMake(kMaxWidthSingleHPBar, kHeightHPBar);
    self.underHpBar.anchorPoint = CGPointMake(0, 0);
    self.underHpBar.position = CGPointMake(-350, -20);
    [hpBorder addChild:self.underHpBar];
    self.underHpBar.zPosition = self.hpBar.zPosition - 1;
}

- (void)increaseGamescoreBy:(float)score{
    self.gameScore += score;
    [self increaseManaBy:score];
}

- (void) increaseManaBy:(float)mana{
    if(!self.playerJet.isUsingSpecialMove){
        self.playerJet.currentMana += mana;
    }
}

- (void)increaseEnemyKilled {
    // Only count enemies killed before boss
    if (!foundBoss && _gameAchievement.enemyKilled < _gameAchievement.totalEnemy) {
        _gameAchievement.enemyKilled++;
    }
}

- (void)playerDidUseRevival {
    _gameAchievement.didUseRevival = true;
}

- (void)playerDidKillBoss {
    _gameAchievement.didKillBoss = true;
    [self addAchievementToScore];
}

- (void)addAchievementToScore {
    _gameAchievement.finalHealth = _playerJet.health;
    [self increaseGamescoreBy:[_gameAchievement getScores]];
}

#pragma mark - Point Conversion
- (CGPoint)convertLevelLayoutMapPointToWorldPoint:(CGPoint)location
{
    CGFloat ratio = self.frame.size.width / kLevelMapLayoutWidth;
    return CGPointMake(location.x * ratio,  location.y * ratio);
}

- (EnemyType)determineEnemyTypeAtLocation:(CGPoint)location
{
    NSUInteger y = (NSUInteger) floor(location.y);
    NSUInteger x = (NSUInteger) floor(location.x);
    
    NSUInteger index = y * kLevelMapLayoutWidth * 4 + x * 4;
    uint8_t * pixel = (void *) &self.levelMap[index];
    
    NSUInteger red = pixel[1];
    NSUInteger green = pixel[2];
    NSUInteger blue = pixel[3];
    
    RGBColor color = {red, green, blue};
    
    if ([Utilities areSameRGBColor:color and:kFireEnemyLayoutColor]) {
        return kFireEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kDefaultEnemyLayoutColor]) {
        return kDefaultEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kNinjaEnemyLayoutColor]) {
        return kNinjaEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kIceEnemyLayoutColor]) {
        return kIceEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kSuicideEnemyLayoutColor]) {
        return kSuicideEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kRockEnemyLayoutColor]) {
        return kRockEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kShockEnemyLayoutColor]) {
        return kShockEnemy;
    }
    if ([Utilities areSameRGBColor:color and:kBossLayoutColor]) {
        if (sLevelId == 1) {
            return kFirstBoss;
        }
        if (sLevelId == 2) {
            return kSecondBoss;
        }
        
        if (sLevelId == 3) {
            return kThirdBoss;
        }
        
        if (sLevelId == 4) {
            return kFourthBoss;
        }
        
        if(sLevelId == 5) {
            NSLog(@"TEST");
            return kFourthBoss;
        }
    }
    
    return kNoEnemy;
}

- (void)didSimulatePhysics {
    if (self.moveBackgroundFlag) {
        // Move background
        SKNode * backgroundNode = self.layers[kBackgroundLayer];
        backgroundNode.position = CGPointMake(backgroundNode.position.x, backgroundNode.position.y - 0.5);
        
        [self.layers[kBackgroundLayer] enumerateChildNodesWithName:@"wall" usingBlock:^(SKNode * node, BOOL * stop) {
            node.position = CGPointMake(node.position.x, node.position.y + 0.5);
        }];
        
        // Remove past background
        SKSpriteNode * currentBackground = self.backgroundSpriteNodes[0];
        if (backgroundNode.position.y + currentBackground.position.y + currentBackground.frame.size.height < 0) {
            [currentBackground removeFromParent];
            [self.backgroundSpriteNodes removeObjectAtIndex:0];
        }
        if ([self.backgroundSpriteNodes count] == 1) {
            self.moveBackgroundFlag = NO;
        }
        
        // Move enemy layer
        SKNode * enemyLayerNode = self.layers[kEnemyLayer];
        enemyLayerNode.position = CGPointMake(enemyLayerNode.position.x, enemyLayerNode.position.y - 0.5);
        
        [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode * node, BOOL * stop) {
            node.position = CGPointMake(node.position.x, node.position.y + 0.5);
        }];
        
        [self makeEnemyAppear];
    }
    
    // Preserve the speed of enemy jet in physics body's velocity
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
        EnemyJet * enemyNode = (EnemyJet *)node;
        if ((!enemyNode.mobile) || (enemyNode.currentState == STATE_DEATH)) {
            enemyNode.physicsBody.velocity = CGVectorMake(0, 0);
        } else if (!enemyNode.isSlowed) {
            Vector2D * velocity = [Vector2D vectorFromCGVector:node.physicsBody.velocity];
            velocity = [velocity normalize];
            if ([velocity isZero]) {
                velocity = [Vector2D vectorWithX:1 andY:0];
            }
            enemyNode.physicsBody.velocity = [[velocity scalarMultiply:enemyNode.jetSpeed] toCGVector];
        }
    }];
    
    // Move enemies outside scene back to scene
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
        EnemyJet * enemyNode = (EnemyJet *)node;
        
        CGPoint worldPoint = [self convertPoint:enemyNode.position fromNode:self.layers[kEnemyLayer]];
        
        /*if (worldPoint.x < 0) {
            enemyNode.position = CGPointMake(enemyNode.position.x - worldPoint.x + 1.5 * enemyNode.radius,
                                             enemyNode.position.y);
        } else {
            if (worldPoint.x > self.frame.size.width) {
                CGFloat moveX = worldPoint.x - self.frame.size.height + 1.5 * enemyNode.radius;
                enemyNode.position = CGPointMake(enemyNode.position.x - moveX,
                                                 enemyNode.position.y);
            }
        }*/
        
        if (worldPoint.y > self.frame.size.height - kHeightHPBar + enemyNode.radius) {
            enemyNode.isAbleToFire = NO;
        }
        
        if (worldPoint.y > self.frame.size.height - kHeightHPBar + enemyNode.radius) {
            if (enemyNode.isPushed) {
                CGFloat scoreGain = [enemyNode.class scoreGain];
                [self increaseGamescoreBy:scoreGain];
                [self increaseEnemyKilled];
                [enemyNode removeFromParent];
                return;
            }
        }
        
        if (worldPoint.y > self.frame.size.height + enemyNode.radius ||
            (!self.moveBackgroundFlag && worldPoint.y > self.frame.size.height - kHeightHPBar)) {
            if (!enemyNode.isPushed) {
                enemyNode.isAbleToFire = NO;
                enemyNode.physicsBody.velocity = CGVectorMake(0, -3 * enemyNode.jetSpeed);
                enemyNode.isMovingToScene = YES;
            }
        }
        
        if (enemyNode.isMovingToScene) {
            if ((self.moveBackgroundFlag && worldPoint.y < self.frame.size.height) ||
                (!self.moveBackgroundFlag && worldPoint.y < self.frame.size.height - kHeightHPBar - enemyNode.radius)) {
                enemyNode.isMovingToScene = NO;
                enemyNode.physicsBody.velocity = [enemyNode getOriginalVelocity];
                enemyNode.isAbleToFire = !self.playerJet.isConfuseEnemy;
                enemyNode.isImmuneToBullet = NO;
            }
        }
        
        if (worldPoint.y < self.frame.size.height - kHeightHPBar + enemyNode.radius) {
            enemyNode.isAbleToFire = !self.playerJet.isConfuseEnemy;
        }
    }];
    
    // Update
    [self updateHUDForPlayer];
}

- (void)update:(CFTimeInterval)currentTime{    
    [self.musicPlayer updateOnset];
    self.playerJet.bulletType  = [self.musicPlayer determineBulletType];
    
    // Remove past bullets
    NSMutableArray* specialMoveBulletArray = [[NSMutableArray alloc] init];
    [self.layers[kPlayerLayer] enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *node, BOOL *stop) {
        PlayerBullet *bullet = (PlayerBullet *)node;
        CGPoint newPosition = [self convertPoint:bullet.position fromNode:self.layers[kPlayerLayer]];
        CGFloat rightMost = newPosition.x + bullet.size.width / 2;
        CGFloat leftMost = newPosition.x - bullet.size.width / 2;
        CGFloat topMost = newPosition.y + bullet.size.height / 2;
        CGFloat bottomMost = newPosition.y - bullet.size.height / 2;
        
        if (rightMost < 0 || topMost < 0 || leftMost > self.view.frame.size.width ||
            bottomMost > self.view.frame.size.height - kHeightHPBar - 35) {
            [bullet removeFromParent];
            return;
        }
        
        if ([self isAffectedBySpecialMove:bullet]){
            [specialMoveBulletArray addObject:bullet];
        }
    }];
    
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *node, BOOL *stop) {
        EnemyBullet *bullet = (EnemyBullet *)node;
        CGPoint newPosition = [self convertPoint:bullet.position fromNode:self.layers[kEnemyLayer]];
        CGFloat rightMost = newPosition.x + bullet.size.width / 2;
        CGFloat leftMost = newPosition.x - bullet.size.width / 2;
        CGFloat topMost = newPosition.y + bullet.size.height / 2;
        CGFloat bottomMost = newPosition.y - bullet.size.height / 2;
        
        if (rightMost < 0 || topMost < 0 || leftMost > self.view.frame.size.width ||
            bottomMost > self.view.frame.size.height - kHeightHPBar) {
            [bullet removeFromParent];
        } else {
            if (bullet.physicsBody.categoryBitMask & kEnemyBullet) {
                Vector2D * originalVelocity = [Vector2D vectorFromCGVector:bullet.originalVelocity];
                CGFloat additionalSpeed = [self.musicPlayer getAdditionalSpeedForEnemyBullet];
                CGFloat newSpeed = originalVelocity.length + additionalSpeed;
                bullet.physicsBody.velocity = [[originalVelocity scalarMultiply:newSpeed / originalVelocity.length]
                                           toCGVector];
            }
        }
    }];

    // Remove past enemies
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
        EnemyJet * enemyNode = (EnemyJet *)node;
        
        CGPoint worldPosition = [self convertPoint:enemyNode.position fromNode:self.layers[kEnemyLayer]];
        
        // Boss is handled differently
        if (enemyNode.physicsBody.categoryBitMask == kBossJet) {
            if ([enemyNode actionForKey:kMovingEnemyActionKey]) {
                return;
            }
            
            if ((worldPosition.y < enemyNode.radius) ||
                (!self.moveBackgroundFlag && worldPosition.y < self.size.height / 2 - enemyNode.radius)) {
                // Animate boss out and back to scene
                enemyNode.isAbleToFire = NO;
                enemyNode.isMovingToScene = YES;
                
                SKAction * moveOut = [SKAction moveByX:0
                                                     y:(-worldPosition.y - enemyNode.radius)
                                              duration:0.6];
                SKAction * moveXOutside = [SKAction moveByX:self.size.width - worldPosition.x + enemyNode.radius
                                                          y:0
                                                   duration:0.05];
                
                // Generate a random X position for boss to appear
                NSUInteger xMin = (NSUInteger)ceil(enemyNode.radius);
                NSUInteger xMax = (NSUInteger)floor(self.size.width - enemyNode.radius);
                CGFloat newX = arc4random() % (xMax - xMin) + xMin;
                CGFloat newY = self.size.height + 2 * enemyNode.radius;
                CGPoint newWorldPosition = CGPointMake(newX, newY);
                CGPoint newBossPosition = [self.layers[kEnemyLayer] convertPoint:newWorldPosition
                                                                        fromNode:self];
                
                SKAction * moveToNewY = [SKAction moveToY:newBossPosition.y duration:0.05];
                SKAction * moveToNewX = [SKAction moveToX:newBossPosition.x duration:0.05];
                SKAction * moveBossAction = [SKAction sequence:
                                             @[moveOut, moveXOutside, moveToNewY, moveToNewX]];
                
                [enemyNode runAction:moveBossAction withKey:kMovingEnemyActionKey];
            }
            
            return;
        }
        
        if (worldPosition.y < 0 || worldPosition.x < 0 || worldPosition.x > self.frame.size.width) {
            [enemyNode removeFromParent];
        }
    }];
    
    [self.playerJet update];
    
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        EnemyJet * enemy = (EnemyJet*)node;
        CGPoint playerLocationInEnemyLayer = [node convertPoint:self.playerJet.position
                                                       fromNode:self.layers[kPlayerLayer]];
        [enemy updateWithHint:YES andPlayerPositionHint:playerLocationInEnemyLayer];
        [enemy fireWithHint:YES andPlayerPositionHint:playerLocationInEnemyLayer];
     }];
    
    NSMutableArray* specialTargetedEnemies = [[NSMutableArray alloc] init];
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        EnemyJet * enemy = (EnemyJet*)node;
        
        if ([self isEnemyToTarget:enemy]){
            [specialTargetedEnemies addObject:enemy];
        }
    }];
    
    NSArray* sortedSpecialTargetedEnemies = [specialTargetedEnemies sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EnemyJet* enemy1 = (EnemyJet*) obj1;
        EnemyJet* enemy2 = (EnemyJet*) obj2;
        
        CGPoint enemy1WorldPosition = [self convertPoint:enemy1.position fromNode:self.layers[kEnemyLayer]];
        CGPoint enemy2WorldPosition = [self convertPoint:enemy2.position fromNode:self.layers[kEnemyLayer]];
        CGPoint playerWorldPosition = [self convertPoint:self.playerJet.position fromNode:self.layers[kPlayerLayer]];
        
        CGFloat dy1 = enemy1WorldPosition.y - playerWorldPosition.y;
        CGFloat dy2 = enemy2WorldPosition.y - playerWorldPosition.y;
        
        if (dy1 < 0 && dy2 > 0){
            return (NSComparisonResult) NSOrderedDescending;
        }
        if (dy1 > 0 && dy2 < 0){
            return (NSComparisonResult) NSOrderedAscending;
        }
        
        NSNumber* cmpDy1 = [NSNumber numberWithFloat:fabs(dy1)];
        NSNumber* cmpDy2 = [NSNumber numberWithFloat:fabs(dy2)];
        
        return [cmpDy1 compare:cmpDy2];
    }];
    
    // Update player bullet of original jet to pursue enemies in special move
    int enemyCount = (int)[sortedSpecialTargetedEnemies count];
    BOOL needPursueEnemy = [self needPursueEnemy];
    if (enemyCount > 0 && needPursueEnemy){
        int fireLines = 1;
        int playerBulletCount = (int)[specialMoveBulletArray count];
        
        for (int i = playerBulletCount - 1; i >=0; i--){
            PlayerBullet* playerBullet = [specialMoveBulletArray objectAtIndex:i];
            
            int pursueEnemyIndex = ((playerBulletCount - 1 - i) % fireLines) % enemyCount;
            EnemyJet* enemy = [sortedSpecialTargetedEnemies objectAtIndex:pursueEnemyIndex];
            CGPoint enemyLocationInPlayerLayer = [playerBullet convertPoint:enemy.position
                                                                     fromNode:self.layers[kEnemyLayer]];
            
            [playerBullet updateWithHint:YES andEnemyPositionHint:enemyLocationInPlayerLayer];
        }
    }
    
    if([self.musicPlayer getCurrentTime] != 0){
        [self.playerJet fire];
    }
    
    NSTimeInterval time = [self.musicPlayer getCurrentTime];
    if (time < lastTime) {
        lastTime = 0.0;
    }
    _gameAchievement.timePlayed += time - lastTime;
    lastTime = time;
}

- (BOOL)isEnemyToTarget:(EnemyJet*)enemy {
    CGPoint enemyWorldPosition = [self convertPoint:enemy.position fromNode:self.layers[kEnemyLayer]];
    
    if (enemy.currentState == STATE_DEATH || enemy.isPushed){
        return NO;
    }
    if (foundBoss && enemy.physicsBody.categoryBitMask == kBossJet){
        return YES;
    }
    if (enemyWorldPosition.y + enemy.radius > self.frame.size.height){
        return NO;
    }
    return YES;
}

- (BOOL)isAffectedBySpecialMove:(PlayerBullet*)bullet{
    if (bullet.bulletType == kPlayerBullet5 && !bullet.canSpread){
        return NO;
    }
    if (!bullet.isAffectedBySpecialMove){
        return NO;
    }
    
    return YES;
}

- (BOOL)needPursueEnemy{
    if (self.playerJet.fireType == kPursueFire){
        return YES;
    }
    if ([PlayerJet modelType] == kOriginal && self.playerJet.isUsingSpecialMove){
        return YES;
    }
    return NO;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // Handle contact / collision here
    GameObject * nodeA = (GameObject *) contact.bodyA.node;
    GameObject * nodeB = (GameObject *) contact.bodyB.node;
    
    if (contact.bodyA.categoryBitMask == kWallRight) {
        [nodeB collidedWithWall:kRightWall];
        return;
    }
    if (contact.bodyA.categoryBitMask == kWallLeft) {
        [nodeB collidedWithWall:kLeftWall];
        return;
    }
    if (contact.bodyB.categoryBitMask == kWallRight) {
        [nodeA collidedWithWall:kRightWall];
        return;
    }
    if (contact.bodyB.categoryBitMask == kWallLeft) {
        [nodeA collidedWithWall:kLeftWall];
    }
    
    [nodeA collidedWith:nodeB.physicsBody];
    [nodeB collidedWith:nodeA.physicsBody];
}

- (void)applyDamage:(CGFloat)damage WithRadius:(CGFloat)radius FromPosition:(CGPoint)position {
    [self.layers[kEnemyLayer] enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode * node, BOOL * stop) {
        EnemyJet * enemyNode = (EnemyJet *)node;
        CGPoint enemyPosition = enemyNode.position;
        CGFloat squaredDistance = (position.x - enemyPosition.x) * (position.x - enemyPosition.x);
        squaredDistance += (position.y - enemyPosition.y) * (position.y - enemyPosition.y);
        CGFloat distance = sqrt(squaredDistance);
        
        if (distance <= radius) {
            [enemyNode applyDamage:damage];
        }
    }];
}

- (void)pauseGame {
    self.paused = YES;
    self.view.paused = YES;
    [self.musicPlayer pause];
}

- (void)pauseGameForBackground {
    self.paused = YES;
    self.view.paused = YES;
    [self.musicPlayer stopForBackground];
}

- (void)resumeGame {
    self.paused = NO;
    self.view.paused = NO;
    [self.musicPlayer play];
}

- (void)shake:(NSInteger)times
 atAmplitudeX:(NSInteger)amplitudeX
andAmplitudeY:(NSInteger)amplitudeY {
    if(![self.world actionForKey:@"shake"]){
        CGPoint initialPoint = self.world.position;
        NSMutableArray * randomActions = [NSMutableArray array];
        for (int i=0; i<times; i++) {
            NSInteger randX = self.world.position.x+arc4random() % amplitudeX - amplitudeX / 2.0;
            NSInteger randY = self.world.position.y+arc4random() % amplitudeY - amplitudeY / 2.0;
            SKAction *action = [SKAction moveTo:CGPointMake(randX, randY) duration:0.01];
            [randomActions addObject:action];
        }
        SKAction *returnStartPoint = [SKAction moveTo:initialPoint duration:0.0];
        SKAction *rep = [SKAction sequence:@[randomActions, returnStartPoint]];
        
        [self.world runAction:rep withKey:@"shake"];
    }
}


// This static variable is used to indicate whether there is a need for reloading level assets
static BOOL sNeedsLevelReloaded = YES;
+ (BOOL)sNeedsLevelReloaded {
    return sNeedsLevelReloaded;
}

+ (void)setNeedsLevelReloaded:(BOOL)boolValue {
    sNeedsLevelReloaded = boolValue;
}

// This static variable is used to indicate whether there is a need for reloading model assets
static BOOL sNeedsModelReloaded = YES;
+( BOOL)sNeedsModelReloaded {
    return sNeedsModelReloaded;
}

+ (void)setNeedsModelReloaded:(BOOL)boolValue {
    sNeedsModelReloaded = boolValue;
}


static NSUInteger sLevelId = 1;

+ (NSUInteger)sLevelId {
    // EFFECTS: Gets the level id
    
    return sLevelId;
}

+ (void)setLevelId:(NSUInteger)newLevelId {
    // EFFECTS: Sets the level id to this scene
    
    sLevelId = newLevelId;
    if(sLevelId == 5){
        [PlayScene setNumBackground:1];
    } else {
        [PlayScene setNumBackground:6];
    }
}

static NSUInteger sNumBackgroundPerLevel = 6;
static NSMutableArray * sBackgroundTextures = nil;

+ (NSUInteger)sNumBackgroundPerLevel {
    // EFFECTS: Gets the number of background images of this level
    
    return sNumBackgroundPerLevel;
}

+ (void)setNumBackground:(NSUInteger)numBackground {
    // EFFECTS: Sets the number of background images of this level
    
    sNumBackgroundPerLevel = numBackground;
}

- (NSMutableArray *)backgroundTextures {
    // EFFECTS: Gets an array of background textures for this level
    
    return sBackgroundTextures;
}

@end
