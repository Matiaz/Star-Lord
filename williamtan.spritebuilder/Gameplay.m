//
//  Gameplay.m
//  williamtan
//
//  Created by William Tan on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Ship.h"
#import "Star.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay{
    Ship *_currentShip;
    CMMotionManager *_motionManager;
    CCPhysicsNode *_physicsNode;
    float viewHeight, viewWidth;
    Star *_star;
    int _starCount, MAXSTARS, _lastStarX, _lastStarY, _score;
    long _currentTime, _spawnStarTime;
    CCLabelTTF *_scoreLabel;
}

#pragma mark Game Methods

- (void)didLoadFromCCB {
    //Determines how fast the spaceship moves.
    ACCEL = 1000;
    MAXSTARS = 5;
    _spawnStarTime = 60;
    _currentTime = 0;
    _starCount = 1;
    _score = 0;
    
    self.userInteractionEnabled = TRUE;
    _currentShip.physicsBody.allowsRotation = FALSE;
    _physicsNode.collisionDelegate = self;
   // _physicsNode.debugDraw = TRUE;
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    
    //Determines the size of the game.
    _motionManager = [[CMMotionManager alloc] init];
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    
}

- (void)createStars{
    int x,y;
   
    
    if((_currentTime == _spawnStarTime) && (_starCount <= MAXSTARS)){
        x = random() % 263 +30; // max x value is 293
        x = clampf(x, 30, viewWidth-28);
        
        y = random() % 548 + 20; // max y value is 568
        y = clampf(y, 20, viewHeight-21);
        
        if((abs(_lastStarX - x)) > 100 && (abs(_lastStarY - y) > 200)){
            _star = (Star*)[CCBReader load:@"Star"];
            _star.position = ccp(x, y);
            [_physicsNode addChild:_star];
            NSLog(@"Added Star x:%i, y%i", x,y);
            
            _starCount++;
            _spawnStarTime = _spawnStarTime + 60;
            _lastStarX = x;
            _lastStarY = y;
        }
        
        else
            [self createStars];
    }
}

- (void) createAsteroids{
    if(_currentTime < 1000){
        [self setUpAsteroids];
    }
    
}

- (void) setUpAsteroids{
    
}

- (void)update:(CCTime)delta {
    _currentTime++;
    if(_currentTime > _spawnStarTime){
        _currentTime = _spawnStarTime - 60;
    }
    
    NSLog(@"_currentTime = %ld", _currentTime);
    
    //Accelerometer code.
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _currentShip.position.x + acceleration.x * ACCEL * delta;
    newXPosition = clampf(newXPosition, 30, viewWidth-28);
    
    CGFloat newYPosition = _currentShip.position.y + acceleration.y * ACCEL * delta;
    newYPosition = clampf(newYPosition, 20, viewHeight-21);
    _currentShip.position = CGPointMake(newXPosition, newYPosition);
    
    [self createStars];
    [self createAsteroids];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    
}

#pragma mark Collision Methods

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Star:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    CCLOG(@"Something collided with a star!");
    [[_physicsNode space] addPostStepBlock:^{
        [self starRemoved:nodeA];
    } key:nodeA];
}

- (void) starRemoved:(CCNode *)Star {
    _starCount--;
    _score++;
    
   // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
   explosion.position = Star.position;
    // add the particle effect to the same node the seal is on
    [Star.parent addChild:explosion];
    [Star removeFromParent];
}

#pragma mark Accelerometer Methods

- (void)onEnter
{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
}

- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

#pragma mark UI Methods
- (void)pause
{
   
}

- (void)play
{
    //[self schedule:@selector(update) interval:0.5f];
}

- (void)openSettings {
    NSLog(@"Settings activated");
    CCScene *settingsScene = [CCBReader loadAsScene:@"Settings"];
    [[CCDirector sharedDirector] pushScene:settingsScene];
}

#pragma mark Parallax Methods



@end