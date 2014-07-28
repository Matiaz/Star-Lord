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
#import "VisionPack.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CMMotionManager *_motionManager;
    
    Ship *_currentShip;
    Asteroid1 *_asteroid;
    VisionPack *_visionPack;
    Star *_star;
    RepulseAsteroid *_repulseAsteroid;
    CCSprite *_vision;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_visionPackLabel;
    
    int _starCount, MAXSTARS, _lastStarX, _lastStarY, MAXASTEROIDS;
    int _powerUpCount, MAXPOWERUP, _lastPowerUpX, _lastPowerUpY;
    int _visionPackCount, MAXVISIONPACK, _numVisionPackPowerUp;
    long _currentTime, _spawnStarTime;
    long _spawnPowerUpTime;
    long _currentVisionPackTime, _spawnVisionPackTime;
    long earlyGame, midGame, lateGame;
    float MAXVISION, MINVISION, DECREASEVISIONFACTOR, RESTOREVISIONFACTOR, _currentVision;
    float viewHeight, viewWidth;
    BOOL RestoreVisionNow, RestartDecreaseVision;
    
    
}

#pragma mark Game Methods

- (void)didLoadFromCCB {
    ACCEL = 1500;
    _score = 0;
    
    _currentTime = 0;
    _spawnStarTime = 60;
    _starCount = 0;
    MAXSTARS = 5;
    
    _asteroidCount = 0;
    
    _spawnPowerUpTime = 700;
    _powerUpCount = 0;
     MAXPOWERUP = 1;
    
    MINVISION = 5;
    MAXVISION = 16.5;
    DECREASEVISIONFACTOR = 0.015;
    RESTOREVISIONFACTOR = 0.16;
    RestoreVisionNow = false;
    RestartDecreaseVision = false;
    
    _numVisionPackPowerUp = 0;
    _currentVisionPackTime = 0;
    _spawnVisionPackTime = 500;
    _visionPackCount = 0;
    MAXVISIONPACK = 1;
    
    earlyGame = 600;
    midGame = 1200;
    lateGame =  2400;
    
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
    
    if((_currentTime == _spawnStarTime) && (_starCount < MAXSTARS)){// max x value is 293
        x = clampf(random() % 263 + 30, 30, viewWidth-28); // max y value is 568
        y = clampf(random() % 480 + 20, 20, viewHeight-21);
        
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
        x = clampf(random() % 263 + 30, 30, viewWidth-28);
        y = clampf(random() % 480 + 20, 20, viewHeight-21);
        
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

-(void) createVisonPacks{
    int x, y;

    if(_visionPackCount < MAXVISIONPACK &&  _currentVisionPackTime == _spawnVisionPackTime){
        x = clampf(random() % 263 + 30, 30, viewWidth-28);
        y = clampf(random() % 480 + 20, 20, viewHeight-21);
        
            _visionPack = (VisionPack*)[CCBReader load:@"VisionPack"];
            _visionPack.position = ccp(x, y);
            [_physicsNode addChild:_visionPack];
            NSLog(@"Added vision pack x:%i, y%i", x,y);
            
            _visionPackCount++;
            _spawnVisionPackTime = _spawnVisionPackTime + 500;
        }
    }


- (void) createAndRemoveAsteroids{
    int shootAsteroidChance, totalChance;
    totalChance = (random() % 1000) + 1; //1-100
    
    if(_currentTime <= earlyGame){ // First 10 seconds of the game.
        shootAsteroidChance = 5; // Will shoot in 1/100 updates. Therefore it will shoot every 1.667 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 4;
            [self shootAsteroids];
            }
    }

    if((_currentTime > earlyGame) && (_currentTime <= 1200)){ //10 sec
        shootAsteroidChance = 10; // Will shoot in 1/50 updates. Therefore it will shoot every .883 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 5;
            [self shootAsteroids];
        }
    }
    
    if((_currentTime > midGame) && (_currentTime <= 2400)){ //20sec
        shootAsteroidChance = 15; // Will shoot in 3/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            [self shootAsteroids];
        }
    }
    if(_currentTime > lateGame){
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

- (void)decreaseVision{
    
    _vision.position = _currentShip.position;
    
    if(_currentTime == 1 || RestartDecreaseVision == true){
        _currentVision = MAXVISION;
        [_vision setScale: _currentVision];
        RestartDecreaseVision = false;
    }
    else if(_currentVision <= MAXVISION && _currentVision >= MINVISION){
        _currentVision = _currentVision - DECREASEVISIONFACTOR;
        [_vision setScale: _currentVision];
    }
    else{
        _currentVision = MINVISION;
        [_vision setScale:_currentVision];
    }
    
}

-(void)restoreVision{
    _vision.position = _currentShip.position;
    if(_currentVision <= MAXVISION){
        _currentVision = _currentVision + RESTOREVISIONFACTOR;
        [_vision setScale:_currentVision];
        
        if(_currentVision >= MAXVISION){
            RestoreVisionNow = false;
            RestartDecreaseVision = true;
        }
        
        
    }
}
- (void)update:(CCTime)delta{
    _currentTime++;
    if(_currentTime > _spawnStarTime){
        _currentTime = _spawnStarTime - 60;
    }
    
    _currentVisionPackTime++;
    
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
    [self createVisonPacks];
    
    if(RestoreVisionNow == false)
    [self decreaseVision];
    
    if(RestoreVisionNow == true)
    [self restoreVision];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    _visionPackLabel.string = [NSString stringWithFormat:@"%d",_numVisionPackPowerUp];
    NSLog(@"%f", _currentVision);
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
    
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = Star.position;
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

//- (void)pressedLight{
//    if(_numVisionPack > 0){
//        RestoreVisionNow = true;
//        _numVisionPack--;
//    }
//    else
//        NSLog(@"No vision packs");
    
//}

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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair VisionPack:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    CCLOG(@"Something collided with a visionPack!");
    [[_physicsNode space] addPostStepBlock:^{
        [self visionPackRemoved:nodeA];
    } key:nodeA];
}

-(void) visionPackRemoved:(CCNode *)VisionPack{
    [VisionPack removeFromParent];
    _numVisionPackPowerUp++;
    _visionPackCount--;
}

#pragma mark - touch handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_numVisionPackPowerUp > 0){
        RestoreVisionNow = true;
        _numVisionPackPowerUp--;
    }
    else
        NSLog(@"No vision packs");
}

@end