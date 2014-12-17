//
//  LightningBolt.m
//  Aerhythm
//
//  Created by Nguyen Ngoc Nhu Thao on 4/22/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "LightningBolt.h"

void createBolt(float x1, float y1, float x2, float y2, float displace, NSMutableArray *pathArray) {
    if (displace < 1.8f) {
        CGPoint point = CGPointMake(x2, y2);
        [pathArray addObject:[NSValue valueWithCGPoint:point]];
    }
    else {
        float mid_x = (x2+x1)*0.5f;
        float mid_y = (y2+y1)*0.5f;
        mid_x += (arc4random_uniform(100)*0.01f-0.5f)*displace;
        mid_y += (arc4random_uniform(100)*0.01f-0.5f)*displace;
        createBolt(x1, y1, mid_x, mid_y, displace*0.5f, pathArray);
        createBolt(mid_x, mid_y, x2, y2, displace*0.5f, pathArray);
    }
}

@interface LightningBolt()

@property (nonatomic) NSMutableArray *targetPoints;
@property (nonatomic) CGFloat lifetime;
@property (nonatomic) CGFloat lineDrawDelay;
@property (nonatomic) CGFloat thickness;
@property (nonatomic, readwrite) CGFloat totalDrawTime;

@end

@implementation LightningBolt

+ (id)lightningWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lifetime:(CGFloat)lifetime lineDrawDelay:(CGFloat)lineDrawDelay thickness:(CGFloat)thickness{
    
    return [[self alloc]initWithStartPoint:startPoint
                                  endPoint:endPoint
                                  lifetime:lifetime
                             lineDrawDelay:lineDrawDelay
                                 thickness:thickness];
}

- (id)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lifetime:(CGFloat)lifetime lineDrawDelay:(CGFloat)lineDrawDelay thickness:(CGFloat)thickness{
    
    self = [super init];
    
    if (self){
        self.targetPoints = [[NSMutableArray alloc] init];
        self.lifetime = lifetime;
        self.lineDrawDelay = lineDrawDelay;
        self.thickness = thickness;
        
        [self drawBoltFromPoint:startPoint toPoint:endPoint];
    }
    
    return self;
}

- (void)drawBoltFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint {
    float hypot = hypotf(fabsf(endPoint.x - startPoint.x), fabsf(endPoint.y - startPoint.y));
    float displace = hypot*0.25;
    
    NSMutableArray *pathArray = [NSMutableArray array];
    [pathArray addObject:[NSValue valueWithCGPoint:startPoint]];
    createBolt(startPoint.x, startPoint.y, endPoint.x, endPoint.y, displace, pathArray);
    
    for (int i = 0; i < pathArray.count - 1; i = i + 1) {
        [self addLineToBoltWithStartPoint:((NSValue *)pathArray[i]).CGPointValue
                                 endPoint:((NSValue *)pathArray[i+1]).CGPointValue
                                    delay:i*self.lineDrawDelay];
    }
    
    self.totalDrawTime = (pathArray.count - 1) * self.lineDrawDelay;

    SKAction *disappear = [SKAction sequence:@[[SKAction waitForDuration:(pathArray.count - 1)*self.lineDrawDelay + self.lifetime],
                                               [SKAction fadeOutWithDuration:0.25],
                                               [SKAction removeFromParent]]];
    [self runAction:disappear];
}

- (void)addLineToBoltWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint delay:(float)delay {
    if (delay == 0) {
        [self drawLineFromStartPoint:startPoint toEndPoint:endPoint];
    }
    else {
        SKAction *delayAction = [SKAction waitForDuration:delay];
        SKAction *draw = [SKAction runBlock:^{
            [self drawLineFromStartPoint:startPoint toEndPoint:endPoint];
        }];
        [self runAction:[SKAction sequence:@[delayAction, draw]]];
    }
}

- (void)drawLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    const float imageThickness = 2.f;
    float thicknessScale = self.thickness / imageThickness;
    CGPoint startPointInThisNode = startPoint;
    CGPoint endPointInThisNode = endPoint;
    float angle = atan2(endPointInThisNode.y - startPointInThisNode.y,
                        endPointInThisNode.x - startPointInThisNode.x);
    float length = hypotf(fabsf(endPointInThisNode.x - startPointInThisNode.x),
                          fabsf(endPointInThisNode.y - startPointInThisNode.y));
    
    SKSpriteNode *halfCircleA = [SKSpriteNode spriteNodeWithTexture:[self halfCircle]];
    halfCircleA.anchorPoint = CGPointMake(1, 0.5);
    SKSpriteNode *halfCircleB = [SKSpriteNode spriteNodeWithTexture:[self halfCircle]];
    halfCircleB.anchorPoint = CGPointMake(1, 0.5);
    halfCircleB.xScale = -1.f;
    SKSpriteNode *lightningSegment = [SKSpriteNode spriteNodeWithTexture:[self lightningSegment]];
    halfCircleA.yScale = halfCircleB.yScale = lightningSegment.yScale = thicknessScale;
    halfCircleA.zRotation = halfCircleB.zRotation = lightningSegment.zRotation = angle;
    lightningSegment.xScale = length*2;
    
    halfCircleA.blendMode = halfCircleB.blendMode = lightningSegment.blendMode = SKBlendModeAlpha;
    halfCircleA.color = halfCircleB.color = lightningSegment.color = [UIColor yellowColor];
    halfCircleA.colorBlendFactor = halfCircleB.colorBlendFactor = lightningSegment.colorBlendFactor = 1.0;
    
    halfCircleA.position = startPointInThisNode;
    halfCircleB.position = endPointInThisNode;
    lightningSegment.position = CGPointMake((startPointInThisNode.x + endPointInThisNode.x)*0.5f,
                                            (startPointInThisNode.y + endPointInThisNode.y)*0.5f);
    [self addChild:halfCircleA];
    [self addChild:halfCircleB];
    [self addChild:lightningSegment];
}

+ (void)loadSharedAssets {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sHalfCircle = [SKTexture textureWithImageNamed:@"half_circle"];
        sLightningSegment = [SKTexture textureWithImageNamed:@"lightning_segment"];
    });
}

static SKTexture *sHalfCircle = nil;
- (SKTexture*)halfCircle {
    return sHalfCircle;
}

static SKTexture *sLightningSegment = nil;
- (SKTexture*)lightningSegment {
    return sLightningSegment;
}

@end
