//
//  GameData.m
//  williamtan
//
//  Created by William Tan on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameData.h"

@implementation GameData

@synthesize calibrationAccelerationX;
@synthesize calibrationAccelerationY;
@synthesize score;
@synthesize MINVISION;

static GameData *sharedData = nil;

+(GameData*) sharedData
{
    if(sharedData == nil)
    {
        //create our singleton instance
        sharedData = [[GameData alloc] init];
    }
    return sharedData;
}

@end