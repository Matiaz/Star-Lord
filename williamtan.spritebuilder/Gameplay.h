//
//  Gameplay.h
//  williamtan
//
//  Created by William Tan on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCScene.h"
@class Asteroid1;

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate> {
    int ACCEL;
}
@property(nonatomic,assign) int asteroidCount;
@property(nonatomic,assign) int score;

-(void) removeAsteroidFromArray:(Asteroid1 *)asteroid;
@end
