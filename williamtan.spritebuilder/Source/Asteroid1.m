//
//  Asteroid1.m
//  williamtan
//
//  Created by William Tan on 7/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Asteroid1.h"
#import "Gameplay.h"
@implementation Asteroid1

- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"Asteroid1";
    self.zOrder = 10;
}

@end
