//
//  Ship.m
//  williamtan
//
//  Created by William Tan on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ship.h"

@implementation Ship
- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"Ship";
    self.zOrder = 11;
}
@end
