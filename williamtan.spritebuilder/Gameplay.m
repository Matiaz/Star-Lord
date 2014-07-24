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
#import "Asteroid1.h"
#import "RepulseAsteroid.h"
#import "CCSprite.h"

@implementation Gameplay{
    Ship *_currentShip;
    Asteroid1 *_asteroid;
    CMMotionManager *_motionManager;
    CCPhysicsNode *_physicsNode;
    float viewHeight, viewWidth;
    Star *_star;
    RepulseAsteroid *_repulseAsteroid;
    int _starCount, MAXSTARS, _lastStarX, _lastStarY, MAXASTEROIDS;
    int _powerUpCount, MAXPOWERUP, _lastPowerUpX, _lastPowerUpY;
    long _currentTime, _spawnStarTime;
    long _spawnPowerUpTime;
    float MAXVISION, MINVISION, VISIONFACTOR, _currentVision;
    CCLabelTTF *_scoreLabel;
    CCSprite *_vision;
}

#pragma mark Game Methods

- (void)didLoadFromCCB {
    //Determines how fast the spaceship moves.
    ACCEL = 1500;
    MAXSTARS = 5;
    _spawnStarTime = 60;
    _currentTime = 0;
    _starCount = 0;
    _score = 0;
    _asteroidCount = 0;
    
    MAXPOWERUP = 1;
    _spawnPowerUpTime = 700;
    _powerUpCount = 0;
    
    MINVISION = 4;
    MAXVISION = 19;
    VISIONFACTOR = 0.01;
    
    self.userInteractionEnabled = TRUE;
    _currentShip.physicsBody.allowsRotation = FALSE;
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    
    //Determines the size of the game.
    _motionManager = [[CMMotionManager alloc] init];
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    
    _currentShip.positionType = CCPositionTypePoints;
    _vision.positionType = CCPositionTypePoints;
    _currentShip.position = ccp(viewWidth/2, viewHeight/2);
    _vision.position = ccp(viewWidth/2, viewHeight/2);
}

- (void)createStars{
    int x,y;
    
    if((_currentTime == _spawnStarTime) && (_starCount < MAXSTARS)){
        x = random() % 263 + 30; // max x value is 293
        x = clampf(x, 30, viewWidth-28);

        y = random() % 480 + 20; // max y value is 568
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

-(void) createPowerUps{
    int x,y;
    
    if((_currentTime == _spawnPowerUpTime) && (_powerUpCount < MAXPOWERUP)){
        x = random() % 263 + 30; // max x value is 293
        x = clampf(x, 30, viewWidth-28);
        
        y = random() % 480 + 20; // max y value is 568
        y = clampf(y, 20, viewHeight-21);
        
        if((abs(_lastPowerUpX - x)) > 100 && (abs(_lastPowerUpY - y) > 200)){
            _repulseAsteroid = (RepulseAsteroid*)[CCBReader load:@"RepulseAsteroid"];
            _repulseAsteroid.position = ccp(x, y);
            [_physicsNode addChild:_repulseAsteroid];
            NSLog(@"Added repulse powerup x:%i, y%i", x,y);
            
            _powerUpCount++;
            _spawnPowerUpTime = _spawnPowerUpTime + 700;
            _lastPowerUpX = x;
            _lastPowerUpY = y;
        }
        
        else
            [self createPowerUps];
    }

}
- (void) createAndRemoveAsteroids{
    int shootAsteroidChance, totalChance;
    totalChance = (random() % 1000) + 1; //1-100
    
    if(_currentTime <= 600){ // First 10 seconds of the game.
        shootAsteroidChance = 5; // Will shoot in 1/100 updates. Therefore it will shoot every 1.667 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 4;
            [self shootAsteroids];
            }
    }

    if((_currentTime > 600) && (_currentTime <= 1200)){ //10 sec
        shootAsteroidChance = 10; // Will shoot in 1/50 updates. Therefore it will shoot every .883 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 5;
            [self shootAsteroids];
        }
    }
    
    if((_currentTime > 1200) && (_currentTime <= 2400)){ //20sec
        shootAsteroidChance = 15; // Will shoot in 3/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            [self shootAsteroids];
        }
    }
    if(_currentTime > 2400){
        shootAsteroidChance = 20; // Will shoot in 4/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 7;
            [self shootAsteroids];
        }
    }
}

- (void) shootAsteroids{
    int startX, startY, vecX, vecY;
    
    if(_asteroidCount < MAXASTEROIDS){ //shoot from top
        startX = random() % 294;
        startY = 578;
        vecX = 0;
        vecY = random() % -301 - 300;
        
        _asteroid = (Asteroid1*)[CCBReader load:@"Asteroid1"];
        _asteroid.position = ccp(startX, startY);
        _asteroid.gameplay = self;
        [_physicsNode addChild:_asteroid];
        _asteroidCount++;
        [_asteroid.physicsBody applyImpulse:ccp(vecX,vecY)];
        NSLog(@"Asteroid count: %i, Asteroid max: %i", _asteroidCount, MAXASTEROIDS);
    }
}

- (void)calibrateShip{
}

- (void)scaleVision:(float) scaleBy{
    
    if(scaleBy <= MAXVISION && scaleBy >= MINVISION)
        [_vision setScale: scaleBy];
    else
        [_vision setScale: MINVISION];
}

- (void)activateVision{
    _vision.position = _currentShip.position;
    
    if(_currentTime == 1){
        _currentVision = MAXVISION;
        [self scaleVision: _currentVision];
    }
    else{
        _currentVision = _currentVision - VISIONFACTOR;
        [self scaleVision: _currentVision];
    }
    
}

- (void)update:(CCTime)delta{
    _currentTime++;
    if(_currentTime > _spawnStarTime){
        _currentTime = _spawnStarTime - 60;
    }
    
    //Accelerometer code.
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _currentShip.position.x + acceleration.x * ACCEL * delta;
    newXPosition = clampf(newXPosition, 30, viewWidth-28);
    
    CGFloat newYPosition = _currentShip.position.y + acceleration.y * ACCEL * delta;
    newYPosition = clampf(newYPosition, 20, viewHeight-21);
    _currentShip.position = CGPointMake(newXPosition, newYPosition);
    
    [self createStars];
    [self createPowerUps];
    [self createAndRemoveAsteroids];
    [self activateVision];

    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
   NSLog(@"current vision %f", _currentVision);
    
}

#pragma mark Collision Methods

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Star:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    CCLOG(@"Something collided with a star!");
    [[_physicsNode space] addPostStepBlock:^{
        [self starRemoved:nodeA];
    } key:nodeA];
}


-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Ship:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    CCLOG(@"You died!");
    [self openEndScene];
}

-(void)openEndScene{
    NSLog(@"EndScene activated");
    CCScene *endScene = [CCBReader loadAsScene:@"EndScene"];
    [[CCDirector sharedDirector] replaceScene:endScene];

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
    self.paused = NO;
}

- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
    self.paused = YES;
}

#pragma mark UI Methods

- (void)openSettings {
    NSLog(@"Settings activated");
    self.paused = YES;
    CCScene *settingsScene = [CCBReader loadAsScene:@"Settings"];
    [[CCDirector sharedDirector] pushScene:settingsScene];
}

#pragma mark Power Ups

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair RepulseAsteroid:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    CCLOG(@"Something collided with a repluse powerup!");
    [[_physicsNode space] addPostStepBlock:^{
        [self repulseAsteroidRemoved:nodeA];
    } key:nodeA];
}


- (void) repulseAsteroidRemoved:(CCNode *)RepulseAsteroid {
        [RepulseAsteroid removeFromParent];
}

@end