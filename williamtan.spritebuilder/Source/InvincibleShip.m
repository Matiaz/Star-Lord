//
//  InvincibleShip.m
//  williamtan
//
//  Created by William Tan on 8/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "InvincibleShip.h"

@implementation InvincibleShip

- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"InvincibleShip";
}
@end
