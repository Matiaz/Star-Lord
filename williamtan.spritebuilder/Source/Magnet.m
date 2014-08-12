//
//  Magnet.m
//  williamtan
//
//  Created by William Tan on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Magnet.h"

@implementation Magnet

- (void) didLoadFromCCB{
    self.physicsBody.collisionType = @"Magnet";
}

@end
