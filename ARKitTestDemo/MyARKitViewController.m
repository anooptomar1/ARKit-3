//
//  MyARKitViewController.m
//  ARSolarPlay
//
//  Created by DFHZ on 2017/9/6.
//  Copyright © 2017年 alexyang. All rights reserved.
//

#import "MyARKitViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface MyARKitViewController ()<ARSCNViewDelegate,ARSessionDelegate>
//轨迹图距离数组
@property (strong,nonatomic) NSArray *trackNumArr;
//动画持续时长
@property (strong,nonatomic) NSArray<NSNumber*> *animationDurationArr;
//所有的行星数组
@property (strong,nonatomic) NSArray<SCNNode*> *allPlateArr;
//行星的纹理图
@property (strong,nonatomic) NSArray *plateTextureArr;
//AR视图展示
@property (strong,nonatomic) ARSCNView *myCNView;
//AR会话，负责管理相机追踪配置及3D相机坐标
@property (strong,nonatomic) ARSession *arSession;
//会话追踪配置
@property (nonatomic,strong) ARSessionConfiguration *arSessionConfiguration;

#pragma mark -添加节点对象
/*
 *   首先科普下太阳系的结构，太阳系共有八大行星，水星、金星、地球、火星、木星、土星、天王星、海王星，还有颗矮行星冥王星。木星体积最大，且自转周期最快，它和土星、天王星都自带行星环，地球卫星是月球，金星和水星是太阳系中唯二不带卫星的行星。太阳作为恒星本身会自转，而行星除了自转外还会围绕它的恒心公转，由于行星轨道多是椭圆，为了简化难度（偷懒）我们假定他们的公转轨道都是圆形，而地球的自转轨道也是斜的，这些细节后面会进一步完善。
 */
//Node对象,设置按照行星的远近添加
@property (strong,nonatomic) SCNNode *sunNode;//太阳
@property (strong,nonatomic) SCNNode *mercuryNode;//添加的水星
@property (strong,nonatomic) SCNNode *venusNode;//添加金星
@property (strong,nonatomic) SCNNode *earthNode;//地球
@property (strong,nonatomic) SCNNode *moonNode;//月球
@property (strong,nonatomic) SCNNode *earthGroupNode;//地球组
@property (strong,nonatomic) SCNNode *marsNode;//火星
@property (strong,nonatomic) SCNNode *jupiterNode;//木星
@property (strong,nonatomic) SCNNode *saturnNode;//土星
@property (strong,nonatomic) SCNNode *saturnLoopNode;//土星环
@property (strong,nonatomic) SCNNode *saturnGroupNode;//土星组
@property(nonatomic, strong) SCNNode *uranusNode; //天王星
@property (strong,nonatomic) SCNNode *neptuneNode;//海王星
@property (strong,nonatomic) SCNNode *plutoNode;//冥王星
@property (strong,nonatomic) SCNNode *sunHaloNode;//设置灯光
@end

@implementation MyARKitViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview:self.myCNView];
    self.myCNView.delegate = self;
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.arSession pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _trackNumArr = @[@0.86,@1.29,@1.72,@2.14,@2.95,@3.57,@4.19,@4.54,@4.98];
    _animationDurationArr = @[@25.0,@40.0,@30.0,@35.0,@90.0,@80.0,@55.0,@50.0,@100.0];
}
#pragma mark -添加太阳
-(void)addSunNodeToSCNView{
    //1.初始化节点
    _sunNode = [[SCNNode alloc]init];
    //2.添加几何形状
    _sunNode.geometry = [SCNSphere sphereWithRadius:0.25];
    //3.设置位置
    [_sunNode setPosition:SCNVector3Make(0, -0.1, 3)];
    //4.添加纹理
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS  =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
    _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
    //添加到根节点
    [_myCNView.scene.rootNode addChildNode:_sunNode];
    [self addAnimationToSun];
    [self addLight];
}
#pragma mark -添加灯光，处理太阳正面和背面的灯光
-(void)addLight{
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:2.5 height:2.5];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.2;
    [_sunNode addChildNode:_sunHaloNode];
    // 关闭所有灯光自己添加
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor blackColor];
    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    // 衰减开始和结束的位置
    lightNode.light.attenuationEndDistance = 19;
    lightNode.light.attenuationStartDistance = 21;
    // Animation
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        lightNode.light.color = [UIColor whiteColor];
        _sunHaloNode.opacity = 0.5;
    }
    [SCNTransaction commit];
}

#pragma mark -添加地球
-(void)addEarthNodeToSCNView{
    _earthNode = [self addPlateNodeWithRadius:0.05 xOff:0 diffuse:@"art.scnassets/earth/earth-diffuse-mini.jpg" duration:1];
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    
    //地球添加云层
    SCNNode *cloudsNode = [SCNNode node];
    cloudsNode.geometry = [SCNSphere sphereWithRadius:0.06];
    [_earthNode addChildNode:cloudsNode];
    //设置云层的属性
    cloudsNode.opacity = 0.5;
    cloudsNode.geometry.firstMaterial.transparent.contents = @"art.scnassets/earth/cloudsTransparency.png";
    cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
    //设置月亮
    _moonNode = [self addPlateNodeWithRadius:0.01 xOff:0.1 diffuse:@"art.scnassets/earth/moon.jpg" duration:1.5];
    //月球围绕地球转
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 15.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
    //设置一个组别
    _earthGroupNode = [SCNNode node];
    _earthGroupNode.position = SCNVector3Make(0.8, 0, 0);
    [_earthGroupNode addChildNode:_earthNode];
    [_earthGroupNode addChildNode:moonRotationNode];
}

#pragma mark -添加土星
-(void)addSaturnNodeToSCNView{
    _saturnNode = [self addPlateNodeWithRadius:0.12 xOff:0 diffuse:@"art.scnassets/earth/saturn.jpg" duration:1];
    //添加土星环
    _saturnLoopNode = [SCNNode node];
    _saturnLoopNode.opacity = 0.4;
    _saturnLoopNode.geometry = [SCNBox boxWithWidth:0.6 height:0 length:0.6 chamferRadius:0];
    _saturnLoopNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn_loop.png";
    _saturnLoopNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    _saturnLoopNode.rotation = SCNVector4Make(-0.5, -1, 0, M_PI_2);
    _saturnLoopNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    //土星组
    _saturnGroupNode = [SCNNode node];
    _saturnGroupNode.position = SCNVector3Make(1.68, 0, 0);
    [_saturnGroupNode addChildNode:_saturnNode];
    [_saturnGroupNode addChildNode:_saturnLoopNode];
    SCNNode *saturnRotationNode = [SCNNode node];
    [saturnRotationNode addChildNode:_saturnGroupNode];
}
#pragma mark -设置太阳的动画
-(void)addAnimationToSun{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 30.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
}
#pragma mark -初始化节点
-(void)setUpAllMyNode{
    //水星
    _mercuryNode = [self addPlateNodeWithRadius:0.02 xOff:0.4 diffuse:@"art.scnassets/earth/mercury.jpg" duration:1];
    //金星
    _venusNode = [self addPlateNodeWithRadius:0.04 xOff:0.6 diffuse:@"art.scnassets/earth/venus.jpg" duration:1];
    //火星
    _marsNode = [self addPlateNodeWithRadius:0.03 xOff:1.0 diffuse:@"art.scnassets/earth/mars.jpg" duration:1];
    //木星
    _jupiterNode = [self addPlateNodeWithRadius:0.15 xOff:1.4 diffuse:@"art.scnassets/earth/jupiter.jpg" duration:1];
    //天王星
    _uranusNode = [self addPlateNodeWithRadius:0.09 xOff:1.95 diffuse:@"art.scnassets/earth/uranus.jpg" duration:1];
    //海王星
    _neptuneNode = [self addPlateNodeWithRadius:0.08 xOff:2.14 diffuse:@"art.scnassets/earth/neptune.jpg" duration:1];
    //冥王星
    _plutoNode = [self addPlateNodeWithRadius:0.04 xOff:2.319 diffuse:@"art.scnassets/earth/pluto.jpg" duration:1];
}

#pragma mark -初始化各个节点 并设置部分属性
-(SCNNode*)addPlateNodeWithRadius:(CGFloat)radius xOff:(CGFloat)x diffuse:(id)content duration:(CGFloat)duration{
    SCNNode *node = [SCNNode node];//创建节点
    node.geometry = [SCNSphere sphereWithRadius:radius];//创建一个球型 半径为radius
    node.position = SCNVector3Make(x, 0, 0);//设置初始位置
    node.geometry.firstMaterial.diffuse.contents = content;//添加的纹理
    node.geometry.firstMaterial.shininess = 0.1;//指定接收器的亮度值。默认值是1.0
    node.geometry.firstMaterial.specular.intensity = 0.5;//接收机的强度默认值是1.0
    [node runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:duration]]];//旋转动画
    return node;
}

#pragma mark -添加围绕太阳旋转动画
-(void)addAnimationToNode{
    [_allPlateArr enumerateObjectsUsingBlock:^(SCNNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 围绕太阳旋转
        SCNNode *rotationNode = [SCNNode node];
        [rotationNode addChildNode:obj];
        [_sunNode addChildNode:rotationNode];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        animation.duration = [_animationDurationArr[idx] floatValue];
        animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
        animation.repeatCount = FLT_MAX;
        [rotationNode addAnimation:animation forKey:@"mars rotation around sun"];
        [_sunNode addChildNode:rotationNode];
    }];
}
#pragma mark - 添加轨迹图
-(void)addTrackNodeToSCNView{
    for (NSNumber *value in _trackNumArr) {
        CGFloat number = [value floatValue];
        SCNNode *earthOrbit = [SCNNode node];
        earthOrbit.opacity = 0.4;
        earthOrbit.geometry = [SCNBox boxWithWidth:number height:0 length:number chamferRadius:0];
        earthOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
        earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
        earthOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
        earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
        [_sunNode addChildNode:earthOrbit];
    }
}

-(ARSCNView *)myCNView{
    if (_myCNView != nil) {
        return _myCNView; 
    }
    _myCNView = [[ARSCNView alloc]initWithFrame:self.view.bounds];
    _myCNView.delegate = self;
    _myCNView.showsStatistics = YES;//显示帧率
    _myCNView.session = self.arSession;
    [self addSunNodeToSCNView];
    [self addEarthNodeToSCNView];
    [self addSaturnNodeToSCNView];
    [self setUpAllMyNode];
    //保证每个节点都被初始化
    _allPlateArr = @[_mercuryNode,_venusNode,_earthGroupNode,_marsNode,_jupiterNode,_saturnGroupNode,_uranusNode,_neptuneNode,_plutoNode];
    [self addTrackNodeToSCNView];//添加轨迹图
    [self addAnimationToNode];//添加动画
    return _myCNView;
}
#pragma mark -配置信息
-(ARSession *)arSession{
    if (_arSession != nil) {
        return _arSession;
    }
    _arSession = [[ARSession alloc]init];
    _arSession.delegate = self;
    return _arSession;
}

-(ARSessionConfiguration *)arSessionConfiguration{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
    ARWorldTrackingSessionConfiguration *configuration = [[ARWorldTrackingSessionConfiguration alloc]init];
    //2.设置追踪方向（追踪平面，后面会用到）
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    configuration.lightEstimationEnabled = YES;
    _arSessionConfiguration = configuration;
    return _arSessionConfiguration;
}

#pragma mark -ARSessionDelegate 会话位置更新
-(void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    //监听手机的移动，实现近距离查看太阳系细节，为了凸显效果变化值*3
    [_sunNode setPosition:SCNVector3Make(-3 * frame.camera.transform.columns[3].x, -0.1 - 3 * frame.camera.transform.columns[3].y, -2 - 3 * frame.camera.transform.columns[3].z)];
}
@end
