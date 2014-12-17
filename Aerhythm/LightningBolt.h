//
//  LightningBolt.h
//  Aerhythm
//
//  Created by Nguyen Ngoc Nhu Thao on 4/22/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameObject.h"

@interface LightningBolt : GameObject

@property (nonatomic, readonly) CGFloat totalDrawTime;

+ (id)lightningWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lifetime:(CGFloat)lifetime lineDrawDelay:(CGFloat)lineDrawDelay thickness:(CGFloat)thickness;

@end
