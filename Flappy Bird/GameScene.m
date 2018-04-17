//
//  GameScene.m
//  Flappy Bird
//
//  Created by Whisper on 2018/1/24.
//  Copyright © 2018年 pactera. All rights reserved.
//

#import "GameScene.h"

#define birdCategory  0x0
#define birdCollision  0x0

#define pipeCategory  0x1
#define pipeCollision  0x1

#define floorCategory 0x2
#define floorCollision 0x2

#define birdpipeCategory 0x3
#define birdpipeCollision 0x3

@implementation GameScene {
    GameStatus gameStatus;
    
    SKSpriteNode *backImage;
    SKSpriteNode *backImage2;
    
    SKSpriteNode *bird;
    
    SKLabelNode *gameOverLabel;
    SKLabelNode *metersLabel;
    SKLabelNode *batteryLabel;
    
    int meters;
    int lifes;

}

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    
    meters = 0;
    lifes = 1;
    self.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1.0];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.view.bounds];
    self.physicsWorld.contactDelegate = self;
    
    backImage = [[SKSpriteNode alloc] initWithImageNamed:@"bg_day.png"];
    backImage.size = self.size;
    backImage.anchorPoint = CGPointMake(0, 0);
    backImage.position = CGPointMake(0, 0);
    backImage.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [self addChild:backImage];
    
    backImage2 = [[SKSpriteNode alloc] initWithImageNamed:@"bg_day.png"];
    backImage2.size = self.size;
    backImage2.anchorPoint = CGPointMake(0, 0);
    backImage2.position = CGPointMake(backImage.size.width, 0);
    backImage2.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, backImage2.size.width, backImage2.size.height)];
    [self addChild:backImage2];
    
    SKSpriteNode *headfloor = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.size.width, 1)];
    headfloor.anchorPoint = CGPointMake(0, 0);
    headfloor.position = CGPointMake(0, self.size.height-1);
    headfloor.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, headfloor.size.width, headfloor.size.height)];
    headfloor.physicsBody.categoryBitMask = floorCategory;
    headfloor.physicsBody.collisionBitMask = floorCollision;
    headfloor.physicsBody.dynamic = false;
    [self addChild:headfloor];
    
    SKSpriteNode *floor = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.size.width, 1)];
    floor.anchorPoint = CGPointMake(0, 0);
    floor.position = CGPointMake(0, 0);
    floor.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, floor.size.width, floor.size.height)];
    floor.physicsBody.categoryBitMask = floorCategory;
    floor.physicsBody.collisionBitMask = floorCollision;
    floor.physicsBody.dynamic = false;
    [self addChild:floor];
    
    metersLabel = [[SKLabelNode alloc] init];
    metersLabel.text = [NSString stringWithFormat:@"meters:%d       lifes:%d",meters,lifes];
    metersLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    metersLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    metersLabel.position = CGPointMake(self.size.width * 0.5, self.size.height);
    metersLabel.zPosition = 100;
    metersLabel.fontSize = 22;
    [self addChild:metersLabel];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    batteryLabel = [[SKLabelNode alloc] init];
    batteryLabel.text = [NSString stringWithFormat:@"battery:%.0f%%",[UIDevice currentDevice].batteryLevel*100];
    batteryLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    batteryLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    batteryLabel.position = CGPointMake(self.size.width * 0.5, 20);
    batteryLabel.zPosition = 100;
    batteryLabel.fontSize = 12;
    [self addChild:batteryLabel];
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIDeviceBatteryLevelDidChangeNotification
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         // Level has changed
         NSLog(@"Battery Level Change");
         batteryLabel.text = [NSString stringWithFormat:@"battery:%.0f%%",[UIDevice currentDevice].batteryLevel*100];
     }];
    
    bird = [[SKSpriteNode alloc] initWithImageNamed:@"bird0.png"];
    bird.size = CGSizeMake(50, 50);
    bird.name = @"bird";
    bird.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    bird.physicsBody = [SKPhysicsBody bodyWithTexture:bird.texture size:CGSizeMake(15, 15)];
    bird.physicsBody.allowsRotation = false;
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.collisionBitMask = birdCollision;
    bird.physicsBody.contactTestBitMask = pipeCategory | floorCategory;
    bird.zPosition = 20;
    [self addChild:bird];
    
    [self shuffle];
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    if(gameStatus != over){
        [self moveScene];
    }
    
    if(gameStatus == running){
        meters ++;
        metersLabel.text = [NSString stringWithFormat:@"meters:%d       lifes:%d",meters,lifes];
    }
}

- (void)shuffle{
    gameStatus = idle;
    meters = 0;
    lifes = 1;
    metersLabel.text = [NSString stringWithFormat:@"meters:%d       lifes:%d",meters,lifes];
    [self removeAllPipesNode];
    [gameOverLabel removeFromParent];
    
    bird.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    bird.physicsBody.dynamic = false;
    
    [self birdStartFly];
}

- (void)startGame{
    gameStatus = running;
    bird.physicsBody.dynamic = true;
    
    [self startCreateRandomPipesAction];
}

- (void)gameOver{
    gameStatus = over;
    [self birdStopFly];
    [self stopCreateRandomPipesAction];
    
    self.userInteractionEnabled = false;
    [self showGameOverLabel];
}

- (void)showGameOverLabel{
    gameOverLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.position = CGPointMake(self.size.width * 0.5, self.size.height);
    gameOverLabel.zPosition = 50;
    [self addChild:gameOverLabel];
    
    [gameOverLabel runAction:[SKAction moveBy:CGVectorMake(0, -self.size.height * 0.5) duration:0.5] completion:^{
        self.userInteractionEnabled = true;
    }];
}

- (void)moveScene{
    
    backImage.position = CGPointMake(backImage.position.x -2, backImage.position.y);
    backImage2.position = CGPointMake(backImage2.position.x -2, backImage2.position.y);
    
    if (backImage.position.x < -backImage.size.width) {
        backImage.position = CGPointMake( backImage2.position.x + backImage2.size.width, backImage.position.y);
    }
    
    if (backImage2.position.x < -backImage2.size.width) {
        backImage2.position = CGPointMake(backImage.position.x + backImage.size.width, backImage2.position.y);
    }
    
    for (SKSpriteNode *pipeSprite in self.children) {
        if([pipeSprite.name isEqualToString:@"pipe"] && pipeSprite != bird){
            
            pipeSprite.position = CGPointMake(pipeSprite.position.x - 2, pipeSprite.position.y);
            
            if (pipeSprite.position.x < -pipeSprite.size.width * 0.5) {
                
                [pipeSprite removeFromParent];
                
            }
        }
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    switch (gameStatus) {
        case idle:
        {
        [self startGame];
        }
            break;
        case running:
        {
        [bird.physicsBody applyImpulse:CGVectorMake(0, 0.10)];
        }
            break;
        case over:
        {
        [self shuffle];
        }
            break;
        default:
            break;
    }
    
}

- (void)birdStartFly{
    
    SKAction *flyAction = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"bird0.png"],[SKTexture textureWithImageNamed:@"bird1.png"],[SKTexture textureWithImageNamed:@"bird2.png"],[SKTexture textureWithImageNamed:@"bird1.png"]] timePerFrame:0.3];
    [bird runAction:[SKAction repeatActionForever:flyAction] withKey:@"fly"];
    
}

- (void)birdStopFly{
    [bird removeActionForKey:@"fly"];
}

- (void)addPipesWithTopSize:(CGSize )topSize BottomSize:(CGSize )bottomSize{
    
    SKTexture *topTexture = [SKTexture textureWithImageNamed:@"pipe_down.png"];
    SKSpriteNode *topPipe = [SKSpriteNode spriteNodeWithTexture:topTexture size:topSize];
    topPipe.name = @"pipe";
    topPipe.position = CGPointMake(self.size.width + topPipe.size.width * 0.5, self.size.height - topPipe.size.height * 0.5);
    topPipe.physicsBody = [SKPhysicsBody bodyWithTexture:topTexture size:topSize];
    topPipe.physicsBody.dynamic = false;
    topPipe.physicsBody.categoryBitMask = pipeCategory;
    topPipe.physicsBody.collisionBitMask = pipeCollision;
    topPipe.zPosition = 10;
    
    SKTexture *bottomTexture = [SKTexture textureWithImageNamed:@"pipe_up.png"];
    SKSpriteNode *bottomPipe = [SKSpriteNode spriteNodeWithTexture:bottomTexture size:bottomSize];
    bottomPipe.name = @"pipe";
    bottomPipe.position = CGPointMake(self.size.width + bottomPipe.size.width * 0.5, bottomPipe.size.height * 0.5);
    bottomPipe.physicsBody = [SKPhysicsBody bodyWithTexture:bottomTexture size:bottomSize];
    bottomPipe.physicsBody.dynamic = false;
    bottomPipe.physicsBody.categoryBitMask = pipeCategory;
    bottomPipe.physicsBody.collisionBitMask = pipeCollision;
    bottomPipe.zPosition = 10;
    
    SKTexture *birdTexture = [SKTexture textureWithImageNamed:@"bird0.png"];
    SKSpriteNode *birdPipe = [SKSpriteNode spriteNodeWithTexture:birdTexture size:CGSizeMake(50, 50)];
    birdPipe.name = @"pipe";
    birdPipe.position = CGPointMake(self.size.width + bottomPipe.size.width * 0.5, (self.size.height - topPipe.size.height - bottomPipe.size.height) * 0.5 + bottomPipe.size.height);
    birdPipe.physicsBody = [SKPhysicsBody bodyWithTexture:birdTexture size:CGSizeMake(50, 50)];
    birdPipe.physicsBody.dynamic = false;
    birdPipe.physicsBody.categoryBitMask = birdpipeCategory;
    birdPipe.physicsBody.collisionBitMask = birdpipeCollision;
    birdPipe.zPosition = 10;
    
    [self addChild:topPipe];
    [self addChild:bottomPipe];
    [self addChild:birdPipe];

}

- (void)createRandomPipes{
    CGFloat pipeGap = arc4random_uniform(bird.size.height) + bird.size.height * 2.5;
    CGFloat pipeWidth = 60.f;
    CGFloat topPipeHeight = arc4random_uniform(self.size.height - pipeGap);
    CGFloat bottomPipeHeight = self.size.height - pipeGap - topPipeHeight;
    [self addPipesWithTopSize:CGSizeMake(pipeWidth, topPipeHeight) BottomSize:CGSizeMake(pipeWidth, bottomPipeHeight)];
}

- (void)startCreateRandomPipesAction{
    SKAction *waitAct = [SKAction waitForDuration:4 withRange:1];
    SKAction *generatePipeAct = [SKAction runBlock:^{
        [self createRandomPipes];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[waitAct,generatePipeAct]]] withKey:@"createPipe"];
}

- (void)stopCreateRandomPipesAction{
    [self removeActionForKey:@"createPipe"];
}

- (void)removeAllPipesNode{
    for (SKSpriteNode *node in self.children) {
        if([node.name isEqualToString:@"pipe"] && node != bird){
            [node removeFromParent];
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    if(gameStatus != running){
        return;
    }
    
    SKPhysicsBody *bodyA = [[SKPhysicsBody alloc] init];
    SKPhysicsBody *bodyB = [[SKPhysicsBody alloc] init];
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        bodyA = contact.bodyA;
        bodyB = contact.bodyB;
    }else{
        bodyB = contact.bodyA;
        bodyA = contact.bodyB;
    }
    
    NSLog(@"categoryBitMask : %d  --> %d",bodyA.categoryBitMask,bodyB.categoryBitMask);
    
    if((bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory) || (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory)){
        [self gameOver];
    }else if (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == birdpipeCategory){
        SKSpriteNode *node = (SKSpriteNode *)[bodyB node];
        [node removeFromParent];
        lifes = lifes + 1;
        metersLabel.text = [NSString stringWithFormat:@"meters:%d       lifes:%d",meters,lifes];
    }
    else{
        bird.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    }
}

@end

