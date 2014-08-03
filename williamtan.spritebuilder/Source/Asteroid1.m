//
//  Asteroid1.m
//  williamtan
//
//  Created by William Tan on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Asteroid1.h"
#import "Gameplay.h"
@implementation Asteroid1{
int viewHeight, viewWidth;
}

- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"Asteroid1";
    viewHeight = [[CCDirector sharedDirector] viewSize].height; //568
    viewWidth = [[CCDirector sharedDirector] viewSize].width;   //320
    self.zOrder = -1000;
}

- (void)update:(CCTime)delta{
    if((self.position.x < -20 || self.position.x > viewWidth + 20|| self.position.y < 0 -20|| self.position.y > viewHeight + 11)){
        [self removeFromParent];
        [self.gameplay removeAsteroidFromArray: self];
       self.gameplay.asteroidCount--;
        NSLog(@"Asteroid removed. Asteroid count: %i", self.gameplay.asteroidCount);
    }
}
@end
