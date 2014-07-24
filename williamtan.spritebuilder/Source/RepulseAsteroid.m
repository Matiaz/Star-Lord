//
//  RepulseAsteroid.m
//  williamtan
//
//  Created by William Tan on 7/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RepulseAsteroid.h"

@implementation RepulseAsteroid
- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"RepulseAsteroid";
}

@end
