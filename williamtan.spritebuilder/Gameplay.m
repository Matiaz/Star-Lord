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
    Star *_currentStar, *_currentStarInArray;
    RepulseAsteroid *_currentRepulseAsteroid, *_currentPowerUpinArray;
    CCSprite *_vision;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_visionPackLabel;
    
    int _starCount, MAXSTARS, MAXASTEROIDS, currentStarX, currentStarY;
    int _powerUpCount, MAXPOWERUP, currentPowerUpX, currentPowerUpY;
    int _visionPackCount, MAXVISIONPACK, _numVisionPackCollected;
    long _currentTime, _spawnStarTime, _spawnStarRate;
    long _currentPowerUpTime, _spawnPowerUpTime, _spawnPowerUpRate;
    long _currentVisionPackTime, _spawnVisionPackTime, _spawnVisionPackRate;
    long earlyGame, midGame, lateGame;
    float MAXVISION, MINVISION, DECREASEVISIONFACTOR, RESTOREVISIONFACTOR, _currentVision;
    float viewHeight, viewWidth;
    BOOL RestoreVisionNow, ResumeDecreaseVision;
    double dxFromStar, dyFromStar, distFromStar, dxFromShip, dyFromShip, distFromShip, dxFromPowerUp, dyFromPowerUp, distFromPowerUp;
    
    NSMutableArray *asteroidArray, *starArray, *powerUpArray, *VisionPackArray;
    int numOfOverlappingStars, numIteration;
}

#pragma mark Game Methods

- (void)didLoadFromCCB {
    ACCEL = 1500;
    _score = 0;
    
    _currentTime = 0;
    _spawnStarTime = 60;
    _spawnStarRate = _spawnStarTime; //because spawnStarTime will always be increasing, a initial rate needs to be declared.
    _starCount = 0;
    MAXSTARS = 5;
    
    _asteroidCount = 0;
    
    _currentPowerUpTime = 0;
    _spawnPowerUpTime = 50;
    _spawnPowerUpRate = _spawnPowerUpTime;
    _powerUpCount = 0;
    MAXPOWERUP = 1;
    
    MINVISION = 4.5;
    MAXVISION = 16.5;
    DECREASEVISIONFACTOR = 0.015;
    RESTOREVISIONFACTOR = 0.16;
    RestoreVisionNow = false;
    ResumeDecreaseVision = false;
    _currentVision = MAXVISION; //sets the vision when the game starts
    [_vision setScale:_currentVision];
    
    _numVisionPackCollected = 20;
    _currentVisionPackTime = 0;
    _spawnVisionPackTime = 500;
    _spawnVisionPackRate = _spawnVisionPackTime;
    _visionPackCount = 0;
    MAXVISIONPACK = 1;
    
    earlyGame = 600;
    midGame = 1200;
    lateGame =  2400;
    
    numOfOverlappingStars = 0;
    numIteration = 0;
    
    self.userInteractionEnabled = TRUE;
    _currentShip.physicsBody.allowsRotation = FALSE;
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    
    _motionManager = [[CMMotionManager alloc] init];
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    
    _currentShip.positionType = CCPositionTypePoints;
    _vision.positionType = CCPositionTypePoints;
    _currentShip.position = ccp(viewWidth/2, viewHeight/2);
    _vision.position = ccp(viewWidth/2, viewHeight/2);
    
    asteroidArray = [NSMutableArray array];
    starArray = [NSMutableArray array];
}

//-(void) createStarsecond{
//    if((_currentTime == _spawnStarTime) && (_starCount < MAXSTARS)){
//        BOOL doneChecking = FALSE;
//        BOOL oldDoneChecking = FALSE;
//        BOOL allDone = TRUE;
//        while (allDone) {
//            currentStarX = clampf(random() % 263 + 30, 30, viewWidth-28); // max x value is 293
//            currentStarY = clampf(random() % 480 + 20, 20, viewHeight-21); // max y value is 568
//            doneChecking = FALSE;
//            oldDoneChecking = FALSE;
//            for(Star* item in starArray){
//                _currentStarInArray = item;
//
//                dx = (currentStarX - _currentStarInArray.position.x);
//                dy = (currentStarY - _currentStarInArray.position.y);
//                dist = sqrt(dx*dx + dy*dy);
//                NSLog(@"%f", dist);
//                oldDoneChecking = doneChecking;
//                doneChecking = dist<100;
//
//                doneChecking = oldDoneChecking || doneChecking;
//
//            }
//
//            allDone = doneChecking;
//        }
//        _currentStar = (Star*)[CCBReader load:@"Star"];
//
//        _currentStar.position = ccp(currentStarX, currentStarY);
//        [_physicsNode addChild:_currentStar];
//        NSLog(@"Added Star x:%i, y%i", currentStarX,currentStarY);
//
//        [starArray addObject:_currentStar];
//
//        _starCount++;
//        _spawnStarTime = _spawnStarTime + _spawnStarRate;
//
//
//    }
//}

-(void) createStars{
    bool done;
    int numOverlappingStars;
    
    if((_currentTime == _spawnStarTime) && (_starCount < MAXSTARS)){
        done = false;
        while(done == false){
            numOverlappingStars = 0;
            currentStarX = clampf(random() % 263 + 30, 30, viewWidth-28); // max x value is 293
            currentStarY = clampf(random() % 480 + 20, 20, viewHeight-21); // max y value is 568
            
            for(int i = 0;i < starArray.count; i++){
                _currentStarInArray = starArray[i];
                
                dxFromStar = (currentStarX - _currentStarInArray.position.x);
                dyFromStar = (currentStarY - _currentStarInArray.position.y);
                distFromStar = sqrt(dxFromStar*dxFromStar + dyFromStar*dyFromStar);
                
                if(distFromStar < 150)
                    numOverlappingStars++;
            }
            for(int i = 0; i < powerUpArray.count; i++){
                _currentPowerUpinArray = powerUpArray[i];
                
                dxFromPowerUp = (currentStarX - _currentPowerUpinArray.position.x);
                dyFromPowerUp = (currentStarY- _currentPowerUpinArray.position.y);
                distFromPowerUp = (dxFromPowerUp*dxFromPowerUp + dyFromPowerUp * dyFromPowerUp);
                
                if(distFromPowerUp < 200)
                    numOverlappingStars++;
            }
            
            dxFromShip = (currentStarX - _currentShip.position.x);
            dyFromShip = (currentStarY - _currentShip.position.y);
            distFromShip = sqrt(dxFromShip*dxFromShip + dyFromShip*dyFromShip);
            if(distFromShip < 125)
                numOverlappingStars++;
            
            if(numOverlappingStars == 0)
                done = true;
        }
        
        if(done == true){
            _currentStar = (Star*)[CCBReader load:@"Star"];
            
            _currentStar.position = ccp(currentStarX, currentStarY);
            [_physicsNode addChild:_currentStar];
            NSLog(@"Added Star x:%i, y%i", currentStarX,currentStarY);
            
            [starArray addObject:_currentStar];
            
            _starCount++;
            _spawnStarTime = _spawnStarTime + _spawnStarRate;
            
        }
    }
}
-(void) createPowerUps{
    bool done;
    int numOverlappingPowerUp;

    if((_currentPowerUpTime == _spawnPowerUpTime) && (_powerUpCount < MAXPOWERUP)){
        done = false;
        while(done == false){
            numOverlappingPowerUp = 0;
            currentPowerUpX = clampf(random() % 263 + 30, 30, viewWidth-28); // max x value is 293
            currentPowerUpY = clampf(random() % 480 + 20, 20, viewHeight-21); // max y value is 568
            
            for(int i = 0; i < powerUpArray.count; i++){
                _currentPowerUpinArray = powerUpArray[i];
                
                dxFromPowerUp = (currentPowerUpX - _currentPowerUpinArray.position.x);
                dyFromPowerUp = (currentPowerUpY- _currentPowerUpinArray.position.y);
                distFromPowerUp = (dxFromPowerUp *dxFromPowerUp + dyFromPowerUp * dyFromPowerUp);
                
                if(distFromPowerUp < 300)
                    numOverlappingPowerUp++;
            }
            
            for(int i = 0;i < starArray.count; i++){
                _currentStarInArray = starArray[i];
                
                dxFromStar = (currentPowerUpX - _currentStarInArray.position.x);
                dyFromStar = (currentPowerUpY - _currentStarInArray.position.y);
                
                distFromStar = sqrt(dxFromStar*dxFromStar + dyFromStar*dyFromStar);
                
                if(distFromStar < 150)
                    numOverlappingPowerUp++;
            }
            dxFromShip = (currentPowerUpX - _currentShip.position.x);
            dyFromShip = (currentPowerUpY - _currentShip.position.y);
            distFromShip = sqrt(dxFromShip*dxFromShip + dyFromShip*dyFromShip);
            if(distFromShip < 125)
                numOverlappingPowerUp++;
            
            if(numOverlappingPowerUp == 0)
                done = true;
        }
        
        if(done == true){
            _currentRepulseAsteroid = (RepulseAsteroid*)[CCBReader load:@"RepulseAsteroid"];
            _currentRepulseAsteroid.position = ccp(currentPowerUpX, currentPowerUpY);
            [_physicsNode addChild:_currentRepulseAsteroid];
            
            [powerUpArray addObject:_currentRepulseAsteroid];
        
            _powerUpCount++;
            _spawnPowerUpTime = _spawnPowerUpTime + _spawnStarRate;

        }
    }
}

-(void) createVisonPacks{
 
        
        _visionPack = (VisionPack*)[CCBReader load:@"VisionPack"];
        _visionPack.position = ccp(x, y);
        [_physicsNode addChild:_visionPack];
        NSLog(@"Added vision pack x:%i, y%i", x,y);
        
        _visionPackCount++;
        _spawnVisionPackTime = _spawnVisionPackTime + _spawnVisionPackRate;
    
}


- (void) createAndRemoveAsteroids{
    int shootAsteroidChance, totalChance;
    totalChance = (random() % 1000) + 1; //1-1000
    
    if(_currentTime <= earlyGame){ // First 10 seconds of the game.
        shootAsteroidChance = 8; // Will shoot in 1/100 updates. Therefore it will shoot every 1.667 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 5;
            [self shootAsteroids];
        }
    }
    
    if((_currentTime > earlyGame) && (_currentTime <= midGame)){ //10 sec
        shootAsteroidChance = 10; // Will shoot in 1/50 updates. Therefore it will shoot every .883 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.018;
        }
    }
    
    if((_currentTime > midGame) && (_currentTime <= lateGame)){ //20sec
        shootAsteroidChance = 12; // Will shoot in 3/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.021;
        }
    }
    if(_currentTime > lateGame){
        shootAsteroidChance = 15; // Will shoot in 4/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.024;
        }
    }
}

- (void) shootAsteroids{
    //    int startX, startY, vecX, vecY, force;
    //
    //    if(_asteroidCount < MAXASTEROIDS){ //shoot from top
    //        force = random() % 200 + 300;
    //
    //        _asteroid = (Asteroid1*)[CCBReader load:@"Asteroid1"];
    //        _asteroid.position = ccp(startX, startY);
    //        _asteroid.gameplay = self;
    //        [_physicsNode addChild:_asteroid];
    //        [asteroidArray addObject:_asteroid];
    //
    //        _asteroidCount++;
    //        [_asteroid.physicsBody applyImpulse:ccpNormalize(ccp(vecX, vecY), force)];
    //
    //        NSLog(@"Asteroid count: %i, Asteroid max: %i", _asteroidCount, MAXASTEROIDS);
    //    }
}

- (void)decreaseVision{
    
    _vision.position = _currentShip.position;
    
    if(ResumeDecreaseVision == true){ //restoreVision is done running
        _currentVision = MAXVISION;
        [_vision setScale: _currentVision];
        ResumeDecreaseVision = false;
    }
    else if(_currentVision <= MAXVISION && _currentVision >= MINVISION){ //when vision is in range, decrease
        _currentVision = _currentVision - DECREASEVISIONFACTOR;
        [_vision setScale: _currentVision];
    }
    else{ //when vision hits min
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
            ResumeDecreaseVision = true;
        }
        
        
    }
}
- (void)update:(CCTime)delta{
    _currentTime++;
    _currentPowerUpTime++;
    _currentVisionPackTime++;
    
    if(_currentTime > _spawnStarTime){      //Keeps _currentTime less than spawnStarTime, so no weird bugs appear.
        _currentTime = _spawnStarTime - 60;
    }
    
    if(_currentPowerUpTime > _spawnPowerUpTime){
        _currentPowerUpTime = _currentPowerUpTime - 60;
    }
    
    
    //    //Accelerometer code.
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _currentShip.position.x + acceleration.x * ACCEL * delta;
    newXPosition = clampf(newXPosition, 30, viewWidth-28);
    
    CGFloat newYPosition = _currentShip.position.y + acceleration.y * ACCEL * delta;
    newYPosition = clampf(newYPosition, 20, viewHeight-21);
    _currentShip.position = CGPointMake(newXPosition, newYPosition);
    
    [self createStars];
    // [self createAndRemoveAsteroids];
    [self createPowerUps];
    [self createVisonPacks];
    
    if(RestoreVisionNow == false)
        [self decreaseVision];
    if(RestoreVisionNow == true)
        [self restoreVision];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    _visionPackLabel.string = [NSString stringWithFormat:@"%d",_numVisionPackCollected];
    //NSLog(@"current time %li", _currentTime);
    //NSLog(@"%i", numTimeCreateStarsIscalled);
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

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Star:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
}

- (void) starRemoved:(CCNode *)Star {
    
    _starCount--;
    _score++;
    
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = Star.position;
    [Star.parent addChild:explosion];
    
    [Star removeFromParent];
    [starArray removeObject:Star];
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

-(void)openEndScene{
    NSLog(@"EndScene activated");
    CCScene *endScene = [CCBReader loadAsScene:@"EndScene"];
    [[CCDirector sharedDirector] replaceScene:endScene];
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
    int asteroidX, asteroidY, shipX, shipY;
    Asteroid1 *_currentAsteroid;
    
    [RepulseAsteroid removeFromParent];
    shipX = _currentShip.position.x;
    shipY = _currentShip.position.y;
    
    for (int i = 0; i < asteroidArray.count; i++) {
        _currentAsteroid = asteroidArray[i];
        asteroidX = _currentAsteroid.position.x;
        asteroidY = _currentAsteroid.position.y;
        
        [_currentAsteroid.physicsBody applyImpulse:ccpMult(ccpNormalize(ccp(asteroidX - shipX,asteroidY - shipY)), 500)];
    }
    
    _powerUpCount--;
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
    _numVisionPackCollected++;
    _visionPackCount--;
}

- (void)removeAsteroidFromArray:(Asteroid1 *) asteroid
{
    [asteroidArray removeObject:asteroid];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_numVisionPackCollected > 0){
        RestoreVisionNow = true;
        _numVisionPackCollected--;
    }
    else
        NSLog(@"No vision packs");
}
@end