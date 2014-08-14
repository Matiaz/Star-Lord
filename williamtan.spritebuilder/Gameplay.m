//
//  Gameplay.m
//  williamtan
//
//  Created by William Tan on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
//Johnny rulez!
#import "Gameplay.h"
#import "Ship.h"
#import "Star.h"
#import "Magnet.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Asteroid1.h"
#import "RepulseAsteroid.h"
#import "CCSprite.h"
#import "VisionPack.h"
#import <UIKit/UIKit.h>
#import "GameData.h"
#import "InvinciblePack.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CMMotionManager *_motionManager;
    Ship *_currentShip;
    Asteroid1 *_currentAsteroid;
    VisionPack *_currentVisionPack, *_currentVisionPackinArray;
    Star *_currentStar, *_currentStarInArray;
    RepulseAsteroid *_currentRepulseAsteroid, *_currentPowerUpinArray;
    InvinciblePack *_currentInvinciblePack;
    Magnet *_currentMagnet;
    CCSprite *_vision, *tapTutorial, *starTutorial, *sunWarning, *flyTutorial;
    CCNode *_closestStars1, *_closestStars2, *_furthurStars1, *_furthurStars2, *_farthestStars1, *_farthestStars2, *_overFarthestStars1, *_overFarthestStars2;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_visionPackLabel;
    CCParticleSystem *VisionParticle;
    
    int shootAsteroidChance, totalChance;
    int _starCount, MAXSTARS, MAXASTEROIDS, currentX, currentY, _asteroidCount, ACCEL;
    int _powerUpCount, MAXPOWERUP;
    int _visionPackCount, MAXVISIONPACK, _numVisionPackCollected;
    long _currentTime, _spawnStarTime, _spawnStarRate;
    long _currentPowerUpTime, _spawnPowerUpTime, _spawnPowerUpRate;
    long _currentVisionPackTime, _spawnVisionPackTime, _spawnVisionPackRate;
    long earlyGame, midGame, lateGame, extremeGame;
    float MAXVISION, MINVISION, DECREASEVISIONFACTOR, RESTOREVISIONFACTOR, _currentVision;
    float viewHeight, viewWidth;
    BOOL RestoreVisionNow, ResumeDecreaseVision;
    BOOL done, isInvincible, startInvincible, startMagnet;
    double dx, dy, dist, spacing;
    
    id moveUp, moveDown;
    
    NSMutableArray *asteroidArray, *starArray, *powerUpArray, *VisionPackArray, *_closestBackground, *_furthurBackground, *_farthestBackground, *_overFarthestBackground;
    int numOverlapping, asteroidShotForce, loopCount, _currentMagnetTime, _stopMagnetTime, _numOfMagnetsCollected, _stopMagnetRate, _attractStarForce, powerUpRandom, _currentInvinciblePackTime, _stopInvinciblePackTime;
    int numDoubleTap;
    NSTimeInterval timeSinceTouch;
    GameData* data;
    
    BOOL startVisionParticle;
    int _currentVisionParticleTime, _stopVisionParticleTime;
    
    BOOL startTapTutorial, startStarTutorial, startSunWarning, shipBlownUp, startFlyTutorial;
    int currentTutorialTimer, nextTutorialTimer, currentScore, sunWarningDuration;
    id sunMoveUp;
}

#pragma mark Game Methods

- (void)didLoadFromCCB {
    _motionManager = [[CMMotionManager alloc] init];
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    
    ACCEL = 1500;
    
    data = [GameData sharedData];
    data.score = 0;
    
    _currentTime = 0;
    _spawnStarTime = 60;
    _spawnStarRate = _spawnStarTime; //because spawnStarTime will always be increasing, a initial rate needs to be declared.
    _starCount = 0;
    MAXSTARS = 5;
    
    _asteroidCount = 0;
    
    _currentPowerUpTime = 0;
    _spawnPowerUpTime = 400;
    _spawnPowerUpRate = _spawnPowerUpTime; //same as above
    _powerUpCount = 0;
    MAXPOWERUP = 1;
    
    data.MINVISION = 4.5;
    MAXVISION = 13.5;
    DECREASEVISIONFACTOR = 0.008;
    RESTOREVISIONFACTOR = 0.16;
    RestoreVisionNow = false;
    ResumeDecreaseVision = false;
    _currentVision = data.MINVISION; //sets the vision when the game starts
    [_vision setScale:_currentVision];
    
    _numVisionPackCollected = 1;
    _currentVisionPackTime = 0;
    _spawnVisionPackTime = 500;
    _spawnVisionPackRate = _spawnVisionPackTime; //same as above
    _visionPackCount = 0;
    MAXVISIONPACK = 1;
    
    earlyGame = 7;
    midGame = 20;
    lateGame = 30;
    extremeGame = 40;
    
    isInvincible = false;
    _currentInvinciblePackTime = 0;
    _stopInvinciblePackTime = 300;
    startInvincible = false;
    
    _currentMagnetTime = 0;
    _stopMagnetTime = 450;
    _attractStarForce = 220;
    startMagnet = false;
    spacing = 90;
    
    startVisionParticle = false;
    _currentVisionParticleTime = 0;
    _stopVisionParticleTime = 200;
    
    startSunWarning = false;
    startTapTutorial = false;
    startStarTutorial = false;
    startFlyTutorial = false;
    
    numDoubleTap = 0;
    currentTutorialTimer = 0;
    nextTutorialTimer = 120;
    sunWarningDuration = 40;
    
    
    moveUp = [CCActionMoveTo actionWithDuration:0.4f position:ccp(viewWidth/2, 50)];
    moveDown = [CCActionMoveTo actionWithDuration:0.4f position:ccp(viewWidth/2, -60)];
    
    [tapTutorial runAction:moveUp];
    
    shipBlownUp = false;
    self.userInteractionEnabled = TRUE;
    _currentShip.physicsBody.allowsRotation = FALSE;
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    
    
    _currentShip.positionType = CCPositionTypePoints;
    _vision.positionType = CCPositionTypePoints;
    _currentShip.position = ccp(viewWidth/2, viewHeight/2);
    _vision.position = ccp(viewWidth/2, viewHeight/2);
    
    asteroidArray = [NSMutableArray array];
    starArray = [NSMutableArray array];
    powerUpArray = [NSMutableArray array];
    VisionPackArray = [NSMutableArray array];
    _closestBackground = [NSMutableArray array];
    [_closestBackground  addObject:_closestStars1];
    [_closestBackground  addObject:_closestStars2];
    _furthurBackground = [NSMutableArray array];
    [_furthurBackground addObject:_furthurStars1];
    [_furthurBackground addObject:_furthurStars2];
    _farthestBackground = [NSMutableArray array];
    [_farthestBackground addObject:_farthestStars1];
    [_farthestBackground addObject:_farthestStars2];
    _overFarthestBackground = [NSMutableArray array];
    [_overFarthestBackground addObject:_overFarthestStars1];
    [_overFarthestBackground addObject:_overFarthestStars2];
    
    
}

-(CGPoint) randomPosition {
    done = false;
    loopCount = 0;
    while(done == false){
        loopCount++;
        numOverlapping = 0;
        currentX = clampf(random() % 263+ 30, 30, viewWidth-28); // max x value is 293
        currentY = clampf(random() % 460+ 25, 20, viewHeight-21); // max y value is 568
        
        for(int i = 0;i < starArray.count; i++){
            _currentStarInArray = starArray[i];
            
            dx = (currentX  - _currentStarInArray.position.x);
            dy = (currentY - _currentStarInArray.position.y);
            dist = sqrt(dx*dx + dy*dy);
            
            if(dist < spacing)
                numOverlapping++;
        }
        
        for(int i = 0; i < powerUpArray.count; i++){
            _currentPowerUpinArray = powerUpArray[i];
            
            dx = (currentX - _currentPowerUpinArray.position.x);
            dy = (currentY - _currentPowerUpinArray.position.y);
            dist = sqrt(dx*dx + dy*dy);
            
            if(dist< spacing)
                numOverlapping++;
        }
        
        for(int i = 0; i < VisionPackArray.count; i++){
            _currentVisionPackinArray = VisionPackArray[i];
            
            dx = (currentX  - _currentVisionPackinArray.position.x);
            dy = (currentY - _currentVisionPackinArray.position.y);
            dist = sqrt(dx*dx + dy*dy);
            
            if(dist< spacing)
                numOverlapping++;
        }
        
        
        dx = (currentX  - _currentShip.position.x);
        dy = (currentY - _currentShip.position.y);
        dist = sqrt(dx*dx + dy*dy);
        if(dist< spacing)
            numOverlapping++;
        
        if(numOverlapping == 0 || loopCount > 1000){
            if(loopCount > 1000){
                NSLog(@"LOOPCOUNT OVER 1000");
            }
            done = true;
        }
    }
    return ccp(currentX,currentY);
}

-(void) createStars{
    if((_currentTime == _spawnStarTime) && (_starCount < MAXSTARS)){
        
        _currentStar = (Star*)[CCBReader load:@"Star"];
        
        _currentStar.position = [self randomPosition];
        [_physicsNode addChild:_currentStar];
        
        [starArray addObject:_currentStar];
        
        _starCount++;
        _spawnStarTime = _spawnStarTime + _spawnStarRate;
        
        
    }
}
-(void) createPowerUps{
    if((_currentPowerUpTime == _spawnPowerUpTime) && (_powerUpCount < MAXPOWERUP)){
        
        powerUpRandom = rand() % 10;
        
        if(powerUpRandom <= 2){ //Magnet 30%
            _currentMagnet = (Magnet*)[CCBReader load: @"Magnet"];
            _currentMagnet.position = [self randomPosition];
            
            [_physicsNode addChild:_currentMagnet];
            [powerUpArray addObject:_currentMagnet];
            
            _powerUpCount++;
            _spawnPowerUpTime = _spawnPowerUpTime + _spawnPowerUpRate;
        }
        
        if(powerUpRandom > 2 && powerUpRandom <= 7){ //Repulse Asteroid 50%
            _currentRepulseAsteroid = (RepulseAsteroid*)[CCBReader load:@"RepulseAsteroid"];
            _currentRepulseAsteroid.position = [self randomPosition];
            
            [_physicsNode addChild:_currentRepulseAsteroid];
            [powerUpArray addObject:_currentRepulseAsteroid];
            
            _powerUpCount++;
            _spawnPowerUpTime = _spawnPowerUpTime + _spawnPowerUpRate;
        }
        
        
        if(powerUpRandom > 7 && powerUpRandom <= 9 ){ //Invincibility 20%
            _currentInvinciblePack = (InvinciblePack*)[CCBReader load: @"InvinciblePack"];
            _currentInvinciblePack.position = [self randomPosition];
            
            [_physicsNode addChild:_currentInvinciblePack];
            [powerUpArray addObject:_currentInvinciblePack];
            
            _powerUpCount++;
            _spawnPowerUpTime = _spawnPowerUpTime + _spawnPowerUpRate;
        }
        
    }
}

-(void) createVisonPacks{
    
    if((_currentVisionPackTime == _spawnVisionPackTime) && (_visionPackCount < MAXVISIONPACK)){
        
        _currentVisionPack = (VisionPack*)[CCBReader load:@"VisionPack"];
        _currentVisionPack.position = [self randomPosition];
        [_physicsNode addChild:_currentVisionPack];
        [VisionPackArray addObject:_currentVisionPack];
        
        _visionPackCount++;
        _spawnVisionPackTime = _spawnVisionPackTime + _spawnVisionPackRate;
    }
}




- (void) createAndRemoveAsteroids{
    //    earlyGame = 10;
    //    midGame = 25;
    //    lateGame = 45;
    //    extremeGame = 65;
    
    totalChance = (random() % 1000) + 1; //1-1000
    
    if(data.score <= earlyGame){ // First 10 seconds of the game.
        shootAsteroidChance = 9; // Will shoot in 1/100 updates. Therefore it will shoot every 1.667 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 3;
            asteroidShotForce = random() % 255 + 170;
            [self shootAsteroids];
        }
    }
    
    else if((data.score > earlyGame) && (data.score <= midGame)){
        shootAsteroidChance = 11; // Will shoot in 1/50 updates. Therefore it will shoot every .883 seconds.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 4;
            asteroidShotForce = random() % 275 + 190;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.009;
        }
    }
    
    else if((data.score > midGame) && (data.score <= lateGame)){
        shootAsteroidChance = 12; // Will shoot in 3/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 5;
            asteroidShotForce = random() % 275 + 205;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.010;
        }
    }
    else if(data.score > lateGame && (data.score <= extremeGame)){
        shootAsteroidChance = 13; // Will shoot in 4/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 6;
            asteroidShotForce = random() % 275 + 215;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.011;
        }
    }
    
    else{
        shootAsteroidChance = 14; // Will shoot in 4/100 updates.
        if(totalChance <= shootAsteroidChance){
            MAXASTEROIDS = 7;
            asteroidShotForce = random() % 285 + 230;
            [self shootAsteroids];
            DECREASEVISIONFACTOR = 0.012;
        }
    }
    
    [self removeAsteroids];
}

- (void) shootAsteroids{
    if(_asteroidCount < MAXASTEROIDS){ //shoot from top
        currentX = random() % 301 +10; //orig is 320, but dont want them to spawn on 0
        currentY = viewHeight + 10;
        
        
        
        int random = arc4random() % 4;
        
        if(random == 0)
            _currentAsteroid = (Asteroid1*)[CCBReader load:@"Asteroid1"];
        else if(random == 1)
            _currentAsteroid = (Asteroid1*)[CCBReader load:@"Asteroid2"];
        else if(random == 2)
            _currentAsteroid = (Asteroid1*)[CCBReader load:@"Asteroid3"];
        else
            _currentAsteroid = (Asteroid1*)[CCBReader load:@"Asteroid4"];
        
        
        _currentAsteroid.position = ccp(currentX, currentY);
        
        _asteroidCount++;
        [_physicsNode addChild:_currentAsteroid];
        [asteroidArray addObject:_currentAsteroid];
        [_currentAsteroid.physicsBody applyImpulse:ccpMult(ccpNormalize(ccp(0,-1)), asteroidShotForce)];
    }
}

- (void)decreaseVision{
    
    _vision.position = _currentShip.position;
    
    if(ResumeDecreaseVision == true){ //restoreVision is done running
        _currentVision = MAXVISION;
        [_vision setScale: _currentVision];
        ResumeDecreaseVision = false;
    }
    else if(_currentVision <= MAXVISION && _currentVision >= data.MINVISION){ //when vision is in range, decrease
        _currentVision = _currentVision - DECREASEVISIONFACTOR;
        [_vision setScale: _currentVision];
    }
    else{ //when vision hits min
        _currentVision = data.MINVISION;
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

-(void) activateVision{
    if(RestoreVisionNow == false)
        [self decreaseVision];
    if(RestoreVisionNow == true)
        [self restoreVision];
}
-(void) activateInvicibility{
    if(startInvincible == true && _currentInvinciblePackTime <= _stopInvinciblePackTime){
        isInvincible = true;
        _currentInvinciblePackTime++;
        NSLog(@"You are invincible %i %i", _currentInvinciblePackTime, _stopInvinciblePackTime);
    }
    else{
        _currentInvinciblePackTime = 0;
        isInvincible = false;
        startInvincible = false;
    }
}
- (void)update:(CCTime)delta{
    _currentTime++;
    _currentPowerUpTime++;
    _currentVisionPackTime++;
    
    if(_currentTime > _spawnStarTime)    //Keeps _currentTime less than spawnStarTime, so no weird bugs appear.
        _currentTime = _spawnStarTime - _spawnStarRate;
    
    if(_currentPowerUpTime > _spawnPowerUpTime)
        _currentPowerUpTime = _spawnPowerUpTime - _spawnPowerUpRate;
    
    if(_currentVisionPackTime > _spawnVisionPackTime)
        _currentVisionPackTime = _spawnVisionPackTime - _spawnVisionPackRate;
    
    if(shipBlownUp == false){
        //Accelerometer code.
        CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        CGFloat newXPosition = _currentShip.position.x + (acceleration.x - data.calibrationAccelerationX) * ACCEL * delta;
        newXPosition = clampf(newXPosition, 30, viewWidth-28);
        
        CGFloat newYPosition = _currentShip.position.y + (acceleration.y - data.calibrationAccelerationY) * ACCEL * delta;
        newYPosition = clampf(newYPosition, 20, viewHeight-21);
        
        _currentShip.position = CGPointMake(newXPosition, newYPosition);
        
        [self createStars];
        [self createPowerUps];
        [self createVisonPacks];
        [self activateMagnet];
        [self activateVision];
        [self activateInvicibility];
        [self createAndRemoveAsteroids];
        [self activateVisionPackParticle];
        [self checkTutorials];
    }
    
    [self scrollBackground];
    
    [_currentShip.physicsBody setVelocity:ccp(0,0)];
    _scoreLabel.string = [NSString stringWithFormat:@"%i",data.score];
    _visionPackLabel.string = [NSString stringWithFormat:@"%d",_numVisionPackCollected];
    // NSLog(@"current time %li", _currentMagnetTime);
    //NSLog(@"%i, %li", _asteroidCount, _currentTime);
    //NSLog(@"%i, %i", _currentMagnetTime, _stopMagnetTime);
    NSLog(@"%i", _asteroidCount);
    
}

#pragma mark Collision Methods
-(bool)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Asteroid1:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    if(isInvincible == false){
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"ShipExplosion"];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = _currentShip.position;
        [_physicsNode addChild:explosion];
        [_currentShip removeFromParent];
        shipBlownUp = true;

        [self scheduleBlock:^(CCTimer *timer) {
            [self openEndScene];
        } delay:1.f];
        
        return true;
    }
    else{
        [[_physicsNode space] addPostStepBlock:^{
            [self repelSingleAsteroid: nodeA];
        } key:nodeA];
        return false;
    }
}
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Star:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self starRemoved:nodeA];
    } key:nodeA];
}


-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair VisionPack:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self visionPackRemoved:nodeA];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair RepulseAsteroid:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self repulseAsteroidRemoved:nodeA];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Magnet:(CCNode *)nodeA Ship:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self magnetRemoved:nodeA];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair InvinciblePack:(CCNode *)nodeA Ship:(CCNode *)nodeB{
    [[_physicsNode space] addPostStepBlock:^{
        [self invinciblePackRemoved:nodeA];
    } key:nodeA];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair RepulseAsteroid:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair VisionPack:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Star:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Magnet:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair InvinciblePack:(CCNode *)nodeA Asteroid1:(CCNode *)nodeB
{
    return false;
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
    self.paused = YES;
    CCScene *settingsScene = [CCBReader loadAsScene:@"Settings"];
    [[CCDirector sharedDirector] pushScene:settingsScene];
}

-(void)openEndScene{
    [self save];
    CCColor *black = [CCColor blackColor];
    CCScene *endScene = [CCBReader loadAsScene:@"EndScene"];
    CCTransition *transition = [CCTransition transitionFadeWithColor: black duration:0.5f];
    [[CCDirector sharedDirector] presentScene:endScene  withTransition:transition];
    
}

#pragma mark Other Collision methods

- (void) starRemoved:(CCNode *)Star {
    
    _starCount--;
    data.score++;
    
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = Star.position;
    [Star.parent addChild:explosion];
    
    [Star removeFromParent];
    [starArray removeObject:Star];
}

- (void) repulseAsteroidRemoved:(CCNode *)RepulseAsteroid {
    CCParticleSystem *repulseAsteroidParticle = (CCParticleSystem *)[CCBReader load:@"RepulseAsteroidParticle"];
    repulseAsteroidParticle.autoRemoveOnFinish = TRUE;
    repulseAsteroidParticle.position = RepulseAsteroid.position;
    [RepulseAsteroid.parent addChild:repulseAsteroidParticle];
    
    [RepulseAsteroid removeFromParent];
    [powerUpArray removeObject:RepulseAsteroid];
    
    for (int i = 0; i < asteroidArray.count; i++) {
        _currentAsteroid = asteroidArray[i];
        [_currentAsteroid.physicsBody setVelocity:ccp(0,0)];
        
        [_currentAsteroid.physicsBody applyImpulse:ccpMult(ccpNormalize(ccp(_currentAsteroid.position.x - _currentShip.position.x,_currentAsteroid.position.y - _currentShip.position.y)), 750)];
    }
    _powerUpCount--;
}

-(void) visionPackRemoved:(CCNode *)VisionPack{
    [VisionPack removeFromParent];
    [VisionPackArray removeObject:VisionPack];
    _numVisionPackCollected++;
    _visionPackCount--;
    
    startVisionParticle = true;
    CCParticleSystem *VisionParticleOnHit = (CCParticleSystem *)[CCBReader load:@"VisionParticleOnHit"];
    VisionParticleOnHit.autoRemoveOnFinish = TRUE;
    VisionParticleOnHit.position = VisionPack.position;
    [_physicsNode addChild:VisionParticleOnHit];
    
    
    VisionParticle = (CCParticleSystem *)[CCBReader load:@"VisionParticle"];
    VisionParticle.autoRemoveOnFinish = TRUE;
    VisionParticle.position = _currentShip.position;
    [_physicsNode addChild:VisionParticle];
    
}

-(void) activateVisionPackParticle{
    if(startVisionParticle == true && _currentVisionParticleTime <= _stopVisionParticleTime){
        VisionParticle.position = _currentShip.position;
        _currentVisionParticleTime++;
    }
    else{
        _currentVisionParticleTime = 0;
        startVisionParticle = false;
    }
    
}
-(void) magnetRemoved: (CCNode *)Magnet{
    [Magnet removeFromParent];
    [powerUpArray removeObject:Magnet];
    _powerUpCount--;
    
    startMagnet = true;
    _currentMagnetTime = 0;
}

- (void)removeAsteroids{
    for(int i = 0; i < asteroidArray.count; i++){
        _currentAsteroid = asteroidArray[i];
        if((_currentAsteroid.position.x < -20 || _currentAsteroid.position.x > viewWidth + 20|| _currentAsteroid.position.y <-20|| _currentAsteroid.position.y > viewHeight + 11)){
            
            [_currentAsteroid removeFromParent];
            [asteroidArray removeObject:_currentAsteroid];
            _asteroidCount--;
        }
    }
}


-(void) repelSingleAsteroid:(CCNode *) Asteroid1{
    for(int i = 0; i < asteroidArray.count; i++){
        if(Asteroid1 == asteroidArray[i]){
            _currentAsteroid = asteroidArray[i];
            [_currentAsteroid.physicsBody applyImpulse:ccpMult(ccpNormalize(ccp(_currentAsteroid.position.x - _currentShip.position.x,_currentAsteroid.position.y - _currentShip.position.y)), 800)];
        }
    }
}

-(void) activateMagnet{
    if(_currentMagnetTime >= _stopMagnetTime && [self checkStars] == true){
        startMagnet = false;
        _currentMagnetTime = 0;
    }
    
    if(startMagnet == true){
        
        [self attractStars];
        _currentMagnetTime++;
    }
    
}



-(void)attractStars{  //applies impulses to all stars toward the ship.
    for(int i = 0; i< starArray.count; i++){
        _currentStar = starArray[i];
        [_currentStar.physicsBody setVelocity:ccp(0, 0)];
        [_currentStar.physicsBody applyImpulse:ccpMult(ccpNormalize(ccp(_currentShip.position.x - _currentStar.position.x,_currentShip.position.y - _currentStar.position.y)), _attractStarForce)];
        
    }
}

-(bool)checkStars{
    bool starIsInBounds = true;
    
    for(int i = 0; i< starArray.count; i++){
        _currentStar = starArray[i];
        if(_currentStar.position.x < -10 || _currentStar.position.x > viewWidth + 10 || _currentStar.position.y < -10 || _currentStar.position.y > viewHeight + 10){  //if the star is out of bounds
            starIsInBounds = false;
            return false;
            break;
        }
    }
    if(starIsInBounds == true){
        for(int i = 0; i < starArray.count; i++){
            _currentStar = starArray[i];
            [_currentStar.physicsBody setVelocity:ccp(0, 0)];
        }
        return true;
        
    }
}


-(void) invinciblePackRemoved: (CCNode *)InvinciblePack{
    startInvincible = true;
    
    [InvinciblePack removeFromParent];
    [powerUpArray removeObject:InvinciblePack];
    _powerUpCount--;
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSTimeInterval secondTouch = event.timestamp-timeSinceTouch;
    
    if (secondTouch < 0.40){
        if(_numVisionPackCollected == 0 && startTapTutorial == false && startStarTutorial == false && [moveDown isDone] == YES && [moveUp isDone] == YES){
            startSunWarning = true;
        }
        if(_numVisionPackCollected > 0){
            RestoreVisionNow = true;
            _numVisionPackCollected--;
            numDoubleTap++;
            
            if(numDoubleTap == 1)
                startTapTutorial = true;
            else
                startTapTutorial = false;
        }
    }
    timeSinceTouch = event.timestamp;
}

#pragma mark - Background methods

-(void)scrollBackground{
    for(CCNode *background in _closestBackground){
        background.position = ccp(background.position.x, background.position.y - 8);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _furthurBackground){
        background.position = ccp(background.position.x, background.position.y - 6);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _farthestBackground){
        background.position = ccp(background.position.x, background.position.y - 4);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
    
    for(CCNode *background in _overFarthestBackground){
        background.position = ccp(background.position.x, background.position.y - 2);
        
        if(background.position.y <= (-1 * background.contentSize.height)){
            background.position = ccp(background.position.x, background.position.y + background.contentSize.height * 2);
        }
    }
}

#pragma mark - tutorials
-(void)checkTutorials{
    if(startTapTutorial == true && [moveUp isDone] == YES){ //if this is thei first double tap and then move up is done
        [tapTutorial runAction:moveDown];
        startStarTutorial = true;
        startTapTutorial = false;
    }
    
    if(startStarTutorial == true){
        currentTutorialTimer++;
        
        if(currentTutorialTimer == nextTutorialTimer){
            [starTutorial runAction:moveUp];
            currentScore = data.score;
        }
        if([moveUp isDone] == YES && data.score == (currentScore + 1) && currentTutorialTimer > nextTutorialTimer){ //if the move up is finished and the user colleted a star. the third parameter is to make sure this is run after starTutorial has been movedUp
            [starTutorial runAction:moveDown];
            currentTutorialTimer = 0;
            startStarTutorial = false;
        }
        
    }
    if(startTapTutorial == false && startStarTutorial == false && startSunWarning == true){
        if(currentTutorialTimer == 0 && [moveDown isDone] == YES) //if this is first iteration and moving down is done
            [sunWarning runAction:moveUp];
        
        currentTutorialTimer++;
        
        if(currentTutorialTimer == sunWarningDuration || _numVisionPackCollected > 0){ //if it is time to move down or a sun has been collected
            [sunWarning runAction:moveDown];
            currentTutorialTimer = 0;
            startSunWarning = false;
        }
    }
    
}
#pragma mark highscores

-(IBAction)save{
    if(data.score > [[MGWU objectForKey:@"highScore"]integerValue]){
        [MGWU setObject:[NSNumber  numberWithInteger:data.score] forKey:@"highScore"];
    }
}


@end