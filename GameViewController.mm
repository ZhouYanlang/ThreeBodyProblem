//
//  GameViewController.m
//  ThreeBodyProblem
//
//  Created by Joshua on 8/23/16.
//  Copyright (c) 2016 joshuacnf. All rights reserved.
//

#import "GameViewController.h"

#define FAC (2.0 * 1e-9)
#define MAX_LINE_CNT 1800
#define CAMERA_PATH_N 2400

@implementation GameViewController
{
    ull tick;
    universe U;
    vec3 Pos[10];
    
    vec3 circlePath[CAMERA_PATH_N + 7];
    SCNNode *gridNode, *unitBoxNode, *cameraNode;
    NSMutableArray *sunArray, *trajectoryBuffer;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    particle P[3];
    memset(P, 0, sizeof(P));
//    P[0] = particle("Sun", 1.98855e30, vec3(0, 0, 0), vec3(0, 0, 0));
//    P[1] = particle("Earth", 5.97237e24, vec3(1.470981e11, 0, 0), vec3(0, 3.0287e4, 0));
    const ldb m0 = 1.98855e30, x0 = 7.354905e10;
    const ldb v0 = sqrt(G * m0 / x0);
    
    P[0] = particle("Sun #1", m0, vec3(-x0 * 0.5, 0, 0),
                    vec3(-v0 * 0.5, v0 * 0.5 * sqrt(3.0), v0 * 0.4));
    P[1] = particle("Sun #2", m0, vec3(x0 * 0.5, 0, 0),
                    vec3(-v0 * 0.5, -v0 * 0.5 * sqrt(3.0), v0 * 0.4));
    P[2] = particle("Sun #3", m0, vec3(0, x0 * 0.5 * sqrt(3.0), 0),
                    vec3(v0, 0, -v0 * 0.8));
    
//    P[0] = particle("Sun #1", m0, vec3(-x0 * (ldb)0.5, 0, 0),
//                    vec3(-v0 * 0.5, v0 * (ldb)0.5 * sqrt(ldb(3.0)), 0));
//    P[1] = particle("Sun #2", m0, vec3(x0 * 0.5, 0, 0),
//                    vec3(-v0 * 0.5, -v0 * (ldb)0.5 * sqrt((ldb)3.0), 0));
//    P[2] = particle("Sun #3", m0, vec3(0, x0 * (ldb)0.5 * sqrt((ldb)3.0), 0),
//                    vec3(v0, 0, 0));
    
//    P[0] = particle("Sun #1", m0, vec3(-x0 * 0.95, 0, 0),
//                    vec3(0, v0 * 0.9, v0 * 0.5));
//    P[1] = particle("Sun #2", m0, vec3(x0 * 0.95, 0, 0),
//                    vec3(0, -v0 * 0.9, v0 * 0.5));
//    P[2] = particle("Sun #3", m0, vec3(0, 0, 0),
//                    vec3(0, 0, -v0));
    
    //const ldb m1 = 5.97237e24, v1 = 3.0287e4;
    U = universe(P, 3);
    
    //init scene
    SCNScene *scene = [SCNScene scene];
    
    sunArray = [NSMutableArray arrayWithCapacity:10];
    SCNNode *sun;
    SCNSphere *sphere = [SCNSphere sphereWithRadius:3.5f];
    sphere.firstMaterial.diffuse.contents = [NSColor grayColor];
    
    //init sun #1
    sun = [SCNNode nodeWithGeometry:sphere];
    sun.position = SCNVector3Make(P[0].r().x * FAC, P[0].r().y * FAC, P[0].r().z * FAC);
    [sunArray addObject:sun];
    [scene.rootNode addChildNode:sun];
    
    //init sun #2
    sun = [SCNNode nodeWithGeometry:sphere];
    sun.position = SCNVector3Make(P[1].r().x * FAC, P[1].r().y * FAC, P[1].r().z * FAC);
    [sunArray addObject:sun];
    [scene.rootNode addChildNode:sun];
    
    //init sun #3
    sun = [SCNNode nodeWithGeometry:sphere];
    sun.position = SCNVector3Make(P[2].r().x * FAC, P[2].r().y * FAC, P[2].r().z * FAC);
    [sunArray addObject:sun];
    [scene.rootNode addChildNode:sun];
    

    //init light node
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, sun.position.y * 0.5 * 1.0 / sqrt(3), 0);
    [scene.rootNode addChildNode:lightNode];
    
    //init ambient light node
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    //init camera node
    const double R = 350.0, H = 180.0;
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.aperture = 1000;
    cameraNode.camera.focalBlurRadius = 0;
    cameraNode.camera.zNear = 0.5;
    cameraNode.camera.zFar = 1000.0;
    cameraNode.camera.focalDistance = sqrt(R * R + H * H);
    
    cameraNode.position = SCNVector3Make(R, 0, H);
    cameraNode.eulerAngles = SCNVector3Make(acos(-1) * 0.5 - atan(H / R), 0, acos(-1) * 0.5);
    [scene.rootNode addChildNode:cameraNode];
    self.gameView.pointOfView = cameraNode;
    
    for (int i = 0; i < CAMERA_PATH_N; i++)
    {
        ldb angle = (acos(-1) * 2.0 * (ldb)i) / (ldb)CAMERA_PATH_N;
        circlePath[i] = vec3(R * cos(angle), R * sin(angle), H);
    } //init camera node path
    
    [cameraNode runAction:
     [SCNAction repeatAction:[SCNAction rotateByX:0 y:0 z:acos(-1) * 2.0
                                         duration:CAMERA_PATH_N / 60.0]
                       count:1e30]];
    cameraNode.paused = YES;
    
    //init unit box node
    unitBoxNode = [SCNNode nodeWithGeometry:
                   [SCNBox boxWithWidth:0.8 height:0.8 length:0.8 chamferRadius:0]];
    unitBoxNode.geometry.firstMaterial.diffuse.contents = [NSColor greenColor];
    
    trajectoryBuffer = [NSMutableArray arrayWithCapacity:MAX_LINE_CNT];
    
    //init grid lines in space
    const float minx = -400.0, maxx = 400.0, dx = 20.0;
    int indices[] = {0, 1};
    SCNVector3 positions[] = { SCNVector3Make(minx, 0, 0), SCNVector3Make(maxx, 0, 0) };
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithVertices:positions count:2];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:1 bytesPerIndex:sizeof(int)];
    SCNGeometry *line = [SCNGeometry geometryWithSources:@[vertexSource] elements:@[element]];
    line.firstMaterial.diffuse.contents = [NSColor darkGrayColor];
    SCNNode *lineNode0 = [SCNNode nodeWithGeometry:line];
    
    SCNNode *lineNode;
    SCNNode *temp = [SCNNode node];
    
    for (float x = minx; x <= maxx; x += dx)
    {
        lineNode = [lineNode0 clone];
        lineNode.position = SCNVector3Make(0, x, 0);
        [temp addChildNode:lineNode];
    }
    
    lineNode0.rotation = SCNVector4Make(0, 0, 1, acos(-1) * 0.5);
    for (float x = minx; x <= maxx; x += dx)
    {
        lineNode = [lineNode0 clone];
        lineNode.position = SCNVector3Make(x, 0, 0);
        [temp addChildNode:lineNode];
    }
    
    gridNode = [temp flattenedClone];
    [scene.rootNode addChildNode:gridNode];
    
    // set the scene to the view
    self.gameView.scene = scene;
    
    // allows the user to manipulate the camera
    //self.gameView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    //self.gameView.showsStatistics = YES;
    
    // configure the view
    self.gameView.backgroundColor = [NSColor blackColor];
    
    // update every frame
    self.gameView.delegate = self;
    
    //init tick
    tick = 0;
}

-(void)play
{
    cameraNode.paused = NO;
}

-(void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    for (int i = 0; i < 17088 * 1.5; i++)
        U.update();
    U.getPositions(Pos);
    
    int k = 0;
    for (SCNNode *sun in sunArray)
    {
        //if (!(tick & 1))
            [self updateTrajectory:sun.position];
        sun.position = SCNVector3Make(Pos[k].x * FAC, Pos[k].y * FAC, Pos[k].z * FAC);
        k++;
    }
    
    vec3 r = circlePath[tick % CAMERA_PATH_N];
    cameraNode.position = SCNVector3Make((float)r.x, (float)r.y, (float)r.z);
    
    tick++;
}

-(void)updateTrajectory:(SCNVector3) A
{
    SCNNode *boxNode = [unitBoxNode clone];
    boxNode.position = A;
    
    [self.gameView.scene.rootNode addChildNode:boxNode];
    [trajectoryBuffer addObject:boxNode];
    
    if ([trajectoryBuffer count] == MAX_LINE_CNT)
    {
        SCNNode *temp = [SCNNode node];
        for (SCNNode *node in trajectoryBuffer)
        {
            [node removeFromParentNode];
            [temp addChildNode:node];
        }
        SCNNode *trajectory = [temp flattenedClone];
        [self.gameView.scene.rootNode addChildNode:trajectory];
        [trajectoryBuffer removeAllObjects];
    }
}

@end
