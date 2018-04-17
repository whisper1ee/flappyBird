//
//  GameScene.h
//  Flappy Bird
//
//  Created by Whisper on 2018/1/24.
//  Copyright © 2018年 pactera. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    idle,
    running,
    over,
} GameStatus;

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@end

