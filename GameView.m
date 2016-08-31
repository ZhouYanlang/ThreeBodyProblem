//
//  GameView.m
//  ThreeBodyProblem
//
//  Created by Joshua on 8/23/16.
//  Copyright (c) 2016 joshuacnf. All rights reserved.
//

#import "GameView.h"

@implementation GameView

@dynamic delegate;

-(void)mouseDown:(NSEvent *)theEvent
{
    [self.delegate performSelector:@selector(play)];
    [super mouseDown:theEvent];
}

@end
