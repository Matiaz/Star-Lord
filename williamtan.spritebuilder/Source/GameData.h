//
//  GameData.h
//  williamtan
//
//  Created by William Tan on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject

@property (nonatomic) double calibrationAccelerationX;
@property (nonatomic) double calibrationAccelerationY;
@property (nonatomic) int score;
@property (nonatomic) float MINVISION;
+(GameData *) sharedData;
@end