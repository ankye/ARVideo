//
//  SCNViewController.m
//  ARKit-Video
//
//  Created by Ahmed Bekhit on 1/11/18.
//  Copyright © 2018 Ahmed Fathi Bekhit. All rights reserved.
//

#import "SCNViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
//#import "transDimenRoom.h"
#import "transDimenStruct.h"

@interface SCNViewController () <ARSCNViewDelegate, RecordARDelegate, RenderARDelegate,ARSessionDelegate>
{
    RecordAR *recorder;
    
    
}
@property(nonatomic,strong)ARSession *arSession;
@property(nonatomic,strong)ARWorldTrackingConfiguration *arWorldTrackingConfiguration;

@property (nonatomic, strong) NSMutableDictionary<NSUUID*, SCNNode*> *planes;
@property (nonatomic, strong) SCNMaterial *gridMaterial;
@property (nonatomic, strong) id cameraContents;
@property (nonatomic, assign) BOOL isCameraBackground;
@property (nonatomic, assign) SCNNode* avator;

//@property (nonatomic, strong) transDimenRoom *room;
@property (nonatomic, assign) BOOL stopDetectPlanes;


@end

@implementation SCNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    //自动调节灯光
    self.sceneView.automaticallyUpdatesLighting = YES;
    //显示状态信息
    self.sceneView.showsStatistics = YES;
    //设置debug选项，
    //ARSCNDebugOptionShowFeaturePoints     显示捕捉到的特征点（小黄点）
    //ARSCNDebugOptionShowWorldOrigin       显示世界坐标原点（相机位置，3D坐标系）
    self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    
    // Create a new scene
//    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
//
//    // Set the scene to the view
//    self.sceneView.scene = scene;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];// [SCNScene new];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    
    //Grid to identify plane detected by ARKit
    _gridMaterial = [SCNMaterial material];
    _gridMaterial.diffuse.contents = [UIImage imageNamed:@"art.scnassets/grid.png"];
    //when plane scaling large, we wanna grid cover it over and over
    _gridMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    _gridMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
    _planes = [NSMutableDictionary dictionary];
    
    //tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeTransDimenRoom:)];
    [self.sceneView addGestureRecognizer:tap];
    
    
    self.sceneView.delegate = self;
  
//    NSError *error;
//    AVCaptureDevice * captureDevice   = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
//    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: captureDevice error: &error];
//    AVCaptureConnection * connection = [videoInput connectionWithMediaType:AVMediaTypeVideo]
    
    // Initialize ARVideoKit recorder
    recorder = [[RecordAR alloc] initWithARSceneKit:self.sceneView];
    
    /*----👇---- ARVideoKit Configuration ----👇----*/
    
    // Set the recorder's delegate
    recorder.delegate = self;
    
    // Set the renderer's delegate
    recorder.renderAR = self;
    
    recorder.fps = 60;
    // Configure the renderer to perform additional image & video processing 👁
    recorder.onlyRenderWhileRecording = YES;
    
    // Configure ARKit content mode. Default is .auto -- aspectFill is recommended for iPhone10-only apps
    recorder.contentMode = ARFrameModeAuto;
    
    // Configure RecordAR to store media files in local app directory
    recorder.deleteCacheWhenExported = NO;
    
    // Configure the envronment light rendering.
    recorder.enableAdjustEnvironmentLighting = YES;
    
    
   
//
//
//    NSArray *animationIDs = [sceneSource identifiersOfEntriesWithClass:[CAAnimation class]];
//    NSUInteger animationCount = [animationIDs count];
//    NSMutableArray *longAnimations = [[NSMutableArray alloc]initWithCapacity:animationCount];
//    CFTimeInterval maxDuration = 0;
//    for (NSInteger index = 0; index<animationCount; index++) {
//        CAAnimation *animation = [sceneSource entryWithIdentifier:animationIDs[index] withClass:[CAAnimation class]];
//        if (animation) {
//            maxDuration = MAX(maxDuration, animation.duration);
//            [longAnimations addObject:animation];
//        }
//    }
//
//    CAAnimationGroup *longAnimationGroup  = [[CAAnimationGroup alloc]init];
//    longAnimationGroup.animations = longAnimations;
//    longAnimationGroup.duration = maxDuration;
//    CAAnimationGroup *idleAnimationGroup = [longAnimationGroup copy];
//    idleAnimationGroup.timeOffset = 20;
//    CAAnimationGroup *lastAnimationGroup = [CAAnimationGroup animation];
//    lastAnimationGroup.animations = @[idleAnimationGroup];
//    lastAnimationGroup.duration = 24.71;
//    lastAnimationGroup.repeatCount = 10000;
//    lastAnimationGroup.autoreverses =YES;
//    SCNNode *personNode = [self.sceneView.scene.rootNode childNodeWithName:@"avatar_attach" recursively:YES];
//    SCNNode *skeletonNode = [self.sceneView.scene.rootNode childNodeWithName:@"skeleton" recursively:YES];
//    [personNode addAnimation:lastAnimationGroup forKey:@"animation"];
    
}

//- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
//    if ([anchor isMemberOfClass: [ARPlaneAnchor class]]) {
//        NSLog(@"捕捉到平地");
//        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
//
//        SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x*0.5 height:0 length:planeAnchor.extent.x * 0.5 chamferRadius:0];
//        plane.firstMaterial.diffuse.contents = [UIColor redColor];
//
//        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//      //  [self.sceneView.scene.rootNode addChildNode:planeNode];
//
//       planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//       // planeNode.position = SCNVector3Make(planeAnchor.center.x , 0, planeAnchor.center.z);
////        [node addChildNode:planeNode];
////        SCNVector3 point = [node convertPosition:SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z) toNode:self.sceneView.scene.rootNode];
////        planeNode.position =point ;// SCNVector3Make(point.x + planeAnchor.center.x , point.y + 0, point.z + planeAnchor.center.z);
//
//        SCNNode *camera = self.sceneView.pointOfView;
//        SCNVector3 position = SCNVector3Make(0, MAX(node.worldTransform.columns[3].y+0.5, 0) , -1);
//        planeNode.position = [camera convertPosition:position toNode:nil];
//        [self.sceneView.scene.rootNode addChildNode:planeNode];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            SCNScene *scene = [SCNScene sceneNamed:@"keai.dae"];
//            SCNNode *vaseNode = scene.rootNode.childNodes[0];
//            vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//            vaseNode.simdScale = 0.01;
//
//            [node addChildNode:vaseNode];
////            self.sceneView.scene = scene;
//        });
//    }
//}

//-(void)tapped:(UIGestureRecognizer *)sender {
//
//    CGPoint touchLocation = [sender locationInView:sender.view];
//    NSArray<ARHitTestResult *> *results = [self.sceneView hitTest:touchLocation types:ARHitTestResultTypeExistingPlane];
//
////    NSArray<SCNHitTestResult *>* hitResults = [self.sceneView hitTest:touchLocation options:nil];
////
////    //    NSLog(@"hittest: %@: ", hitResults);
////
////    if ([hitResults count] != 0) {
////        SCNNode *node = [hitResults firstObject].node;
////        node.geometry.firstMaterial.diffuse.contents = [UIColor greenColor];
////    }
//}


-(void)viewWillAppear:(BOOL)animated {
    // Create a session configuration
   _arWorldTrackingConfiguration = [ARWorldTrackingConfiguration new];
    
    _arWorldTrackingConfiguration.planeDetection = ARPlaneDetectionHorizontal;
    _arWorldTrackingConfiguration.lightEstimationEnabled = YES;

    if (@available(iOS 12.0, *)) {
        _arWorldTrackingConfiguration.environmentTexturing = AREnvironmentTexturingAutomatic;
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 11.3, *)) {
        _arWorldTrackingConfiguration.autoFocusEnabled = NO;
    } else {
        // Fallback on earlier versions
    }
    // Run the view's session
    [self.sceneView.session runWithConfiguration:_arWorldTrackingConfiguration];
    
    // Prepare the recorder with sessions configuration
    [recorder prepare:_arWorldTrackingConfiguration];
    
    _arSession = self.sceneView.session;
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
    
    if(recorder.status == RecordARStatusRecording) {
        [recorder stopAndExport:^(NSURL*_Nonnull filePath, PHAuthorizationStatus status, BOOL ready) {
            if (status == PHAuthorizationStatusAuthorized) {
                NSLog(@"Video Exported Successfully!");
            }
        }];
    }
    recorder.onlyRenderWhileRecording = YES;
    
    // Switch off the orientation lock for UIViewControllers with AR Scenes
    [recorder rest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK:- Capture and Record methods
- (IBAction)capture:(UIButton *)sender {
    if (sender.tag == 0) {
        //Photo
        if (recorder.status == RecordARStatusReadyToRecord) {
            UIImage *image = [recorder photo];
            [recorder exportWithImage:NULL UIImage:image :NULL];
        }
    }else if (sender.tag == 1) {
        //Live Photo
        if (recorder.status == RecordARStatusReadyToRecord) {
            [recorder livePhotoWithExport:YES :NULL];
        }
    }else if (sender.tag == 2) {
        //GIF
        if (recorder.status == RecordARStatusReadyToRecord) {
            [recorder gifForDuration:3.0 export:YES :NULL];
        }
    }
}

- (IBAction)record:(UIButton *)sender {
    if (sender.tag == 0) {
        //Record
        if (recorder.status == RecordARStatusReadyToRecord) {
            [sender setTitle:@"Stop" forState: UIControlStateNormal];
            [self.pauseBtn setTitle:@"Pause" forState: UIControlStateNormal];
            self.pauseBtn.enabled = YES;
            [recorder record];
        }else if (recorder.status == RecordARStatusRecording) {
            [sender setTitle:@"Record" forState: UIControlStateNormal];
            [self.pauseBtn setTitle:@"Pause" forState: UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [recorder stopAndExport:^(NSURL*_Nonnull filePath, PHAuthorizationStatus status, BOOL ready) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"Video Exported Successfully!");
                }
            }];
        }
    }else if (sender.tag == 1) {
        //Record with duration
        if (recorder.status == RecordARStatusReadyToRecord) {
            [sender setTitle:@"Stop" forState: UIControlStateNormal];
            [self.pauseBtn setTitle:@"Pause" forState: UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            self.recordBtn.enabled = NO;
            [recorder recordForDuration:10 :NULL];
        }else if (recorder.status == RecordARStatusRecording) {
            [sender setTitle:@"w/Duration" forState: UIControlStateNormal];
            [self.pauseBtn setTitle:@"Pause" forState: UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            self.recordBtn.enabled = YES;
            [recorder stopAndExport:^(NSURL*_Nonnull filePath, PHAuthorizationStatus status, BOOL ready) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"Video Exported Successfully!");
                }
            }];
        }
    }else if (sender.tag == 2) {
        //Pause
        if (recorder.status == RecordARStatusPaused) {
            [sender setTitle:@"Pause" forState: UIControlStateNormal];
            [recorder record];
        }else if (recorder.status == RecordARStatusRecording) {
            [sender setTitle:@"Resume" forState: UIControlStateNormal];
            [recorder pause];
        }
    }
}

- (IBAction)goBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - place room
-(void)placeTransDimenRoom:(UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.sceneView];
    NSArray<ARHitTestResult*> *results = [self.sceneView hitTest:point
                                                           types:ARHitTestResultTypeExistingPlaneUsingExtent|ARHitTestResultTypeEstimatedHorizontalPlane];
    simd_float3 position = results.firstObject.worldTransform.columns[3].xyz;
//    if(!_room){
//        _room = [transDimenRoom transDimenRoomAtPosition:SCNVector3FromFloat3(position)];
//        _room.name = @"room";
//        [self.sceneView.scene.rootNode addChildNode:_room];
//    }
//    _room.position = SCNVector3FromFloat3(position);
//    _room.eulerAngles = SCNVector3Make(0, self.sceneView.pointOfView.eulerAngles.y, 0);
//
    if(!_avator){
        _avator = [transDimenStruct innnerStructs];
        _avator.name = @"girl";
        [self.sceneView.scene.rootNode addChildNode:_avator];
    }
    _avator.position = SCNVector3FromFloat3(position);
    _avator.eulerAngles = SCNVector3Make(0, self.sceneView.pointOfView.eulerAngles.y, 0);
    
    _stopDetectPlanes = YES;
    [_planes enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, SCNNode * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeFromParentNode];
    }];
    [_planes removeAllObjects];
    
    //TODO:keep room door looking at user
}
- (void)changeBackground:(BOOL)needcCustomBackground{
    if (!self.sceneView.scene.background.contents) {
        return;
    }
    if (!_cameraContents) {
        _cameraContents = self.sceneView.scene.background.contents;
    }
    if (needcCustomBackground) {
        self.sceneView.scene.background.contents = [UIImage imageNamed:@"art.scnassets/skybox01_cube.png"];
    }else{
        self.sceneView.scene.background.contents = _cameraContents;
    }
    _isCameraBackground = needcCustomBackground;
}
-(void)handleUserInRoom:(BOOL)isUserInRoom{
    @synchronized(self){
        static BOOL alreadyInRoom = NO;
        if (alreadyInRoom == isUserInRoom) {
            return;
        }
      //  [self changeBackground:isUserInRoom];
    //    [_room hideWalls:isUserInRoom];
        alreadyInRoom = isUserInRoom;
        
    }
}
#pragma mark - ARSCNViewDelegate

//每次 3D 引擎将要渲染新的帧时都会调用：
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
//    if (_room.presentationNode) {
//
//        SCNVector3 position = self.sceneView.pointOfView.presentationNode.worldPosition;
//
//        SCNVector3 roomCenter = _room.walls.worldPosition;
//        SCNVector3 roomCenter1 = [_room convertPosition:SCNVector3Make(0, 0, -2.5/2) toNode:nil];
//
//        CGFloat distance = GLKVector3Length(GLKVector3Make(position.x - roomCenter.x, 0, position.z - roomCenter.z));
//
//        //User walk into room
//        //        if (positionRelativeToRoom.x > -2.5/2 && positionRelativeToRoom.x < 2.5/2) {
//        //            if (positionRelativeToRoom.z < 0 && positionRelativeToRoom.z > -2.5) {
//        if (distance < 1){
//            NSLog(@"In room");
//            [self handleUserInRoom:YES];
//            return;
//        }
//        //            }
//        //        }
//        //User is outside of room
//        [self handleUserInRoom:NO];
//
//    }
    [self handleUserInRoom:NO];
}


//当添加节点是会调用，我们可以通过这个代理方法得知我们添加一个虚拟物体到AR场景下的锚点（AR现实世界中的坐标）
//每次 ARKit 自认为检测到了平面时都会调用此方法。其中有两个信息，node 和 anchor。SCNNode 实例是 ARKit
//创建的 SceneKit node，它设置了一些属性如 orientation（方向）和 position（位置），然后还有一个 anchor 实例，
//包含此锚点的更多信息，例如尺寸和平面的中心点。

//anchor 实例实际上是 ARPlaneAnchor 类型，从中我们可以得到平面的 extent（范围）和 center（中心点）信息。

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]] && !_stopDetectPlanes){
        NSLog(@"detected plane");
        [self addPlanesWithAnchor:(ARPlaneAnchor*)anchor forNode:node];
        [self postInfomation:@"touch ground to place room"];
       
    }
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        NSLog(@"updated plane");
        
      //  [self updatePlanesForAnchor:(ARPlaneAnchor*)anchor];
    }
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        NSLog(@"removed plane");
        [self removePlaneForAnchor:(ARPlaneAnchor*)anchor];
    }
}
- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}
#pragma mark - planes
- (void)addPlanesWithAnchor:(ARPlaneAnchor*)anchor forNode:(SCNNode*)node{
    // For the physics engine to work properly give the plane some height so we get interactions
    // between the plane and the gometry we add to the scene
    float planeHeight = 0.01;
    CGFloat width = anchor.extent.x;
    CGFloat length = anchor.extent.z;
    
    SCNBox *planeGeometry = [SCNBox boxWithWidth:width height:planeHeight length:length chamferRadius:0];
    //We only need top surface of box to display grid
    SCNMaterial *transparentMaterial = [SCNMaterial new];
    transparentMaterial.diffuse.contents = [UIColor clearColor];
    //We don't wanna transparent material interacts with lights
    transparentMaterial.lightingModelName = SCNLightingModelConstant;
    
    SCNMaterial *topMaterail = _gridMaterial ? : transparentMaterial;
    //update texture scale.
    //When plane grow larger, gird should cover it over and over. Otherwise, gird should be cliped to fit
    topMaterail.diffuse.contentsTransform = SCNMatrix4Scale(SCNMatrix4Identity, planeGeometry.width, planeGeometry.length, 1);
    
    planeGeometry.materials = @[transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, topMaterail, transparentMaterial];
    
    SCNNode *planeNode = [SCNNode nodeWithGeometry:planeGeometry];
    //Move plane down along Y axis to keep flatness
    SCNVector3 position = SCNVector3FromFloat3(anchor.center);
    position.y -= planeHeight/2;
    planeNode.position = position;
    planeNode.name = @"plane";
    planeNode.castsShadow = NO;
    [node addChildNode:planeNode];
    
    [_planes setObject:planeNode forKey:anchor.identifier];
}
- (void)updatePlanesForAnchor:(ARPlaneAnchor*)anchor{
    SCNNode *plane = _planes[anchor.identifier];
    if (!plane) {
        return;
    }

    SCNBox *planeGeometry = (SCNBox *)plane.geometry;
    planeGeometry.width = anchor.extent.x;
    planeGeometry.length = anchor.extent.z;
    
    SCNVector3 position = SCNVector3FromFloat3(anchor.center);
    position.y -= planeGeometry.height/2;
    
    plane.position = position;
    
    SCNMaterial *topMaterail = plane.geometry.materials[4];
    topMaterail.diffuse.contentsTransform = SCNMatrix4Scale(SCNMatrix4Identity, planeGeometry.width, planeGeometry.length, 1);
}
-(void)removePlaneForAnchor:(ARPlaneAnchor*)anchor{
    SCNNode *plane = _planes[anchor.identifier];
    [plane removeFromParentNode];
    [_planes removeObjectForKey:anchor.identifier];
}
#pragma mark - utils
- (void)postInfomation:(NSString*)info{
    static BOOL isShowInfo = NO;
    if (isShowInfo) {
        return;
    }
    isShowInfo = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:info preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:^{
                isShowInfo = NO;
            }];
        });
    }];
}


// MARK:- ARVideoKit protocol methods
- (void)recorderWithDidEndRecording:(NSURL * _Nonnull)path with:(BOOL)noError {
    
}

- (void)recorderWithDidFailRecording:(NSError * _Nullable)error and:(NSString * _Nonnull)status {
    
}

- (void)recorderWithWillEnterBackground:(enum RecordARStatus)status {
    
}

- (void)frameWithDidRender:(CVPixelBufferRef _Nonnull)buffer with:(CMTime)time using:(CVPixelBufferRef _Nonnull)rawBuffer {
    
}



@end
