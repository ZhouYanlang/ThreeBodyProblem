//
//  GameViewController.h
//  ThreeBodyProblem
//
//  Created by Joshua on 8/23/16.
//  Copyright (c) 2016 joshuacnf. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <Cocoa/Cocoa.h>

#import "globals.h"
#import "GameView.h"

@interface GameViewController : NSViewController <SCNSceneRendererDelegate>

@property (assign) IBOutlet GameView *gameView;

-(void)play;

@end
