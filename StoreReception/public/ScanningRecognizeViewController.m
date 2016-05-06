//
//  ScanningRecognizeViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/20.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ScanningRecognizeViewController.h"
#import "ScanningView.h"
#import "PlateRecognize.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ScanHistoryViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@interface ScanningRecognizeViewController (){
    ScanningView *sv;
    NSMutableArray *imgArray;
    NSString *lince;
    UIImage *carImage;
}

@end

@implementation ScanningRecognizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
//        self.edgesForExtendedLayout= UIRectEdgeNone;
//    }
    [self initHeader];
    [self showCamera:nil];
    imgArray = [[NSMutableArray alloc] init];
    WS(ws);
    sv = [[ScanningView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds))];//初始化、坐标
    sv.backgroundColor = [UIColor clearColor];//要透明的
    sv.funType = PLATERECOGNIZE;
    __weak ScanningView *weakScan = sv;
    __block NSMutableArray *bArray = imgArray;
    sv.commitClick = ^(void){
        [ZAActivityBar showWithStatus:LICENSE_REG];
        [ws captureImage:^(BOOL finished, UIImage *captureImage) {
            if (finished) {
                [bArray removeAllObjects];
                carImage = [ws fixOrientation:captureImage];
                UIImageWriteToSavedPhotosAlbum(carImage, nil, nil, nil);
                NSMutableArray *result = [[PlateRecognize sharedPlateRecognize] recognizeFromImage:carImage outImages:bArray];
                if (result.count > 0) {
                    [ZAActivityBar dismiss];
                    [weakScan setBtnEnabled:NO];
                    lince = result[0];
                    if (lince.length == 10) {
                        if ([_type isEqualToString:@"autowash"]) {
                            [self addCarNum];
                        }
                        NSString *linceSub = [lince substringWithRange:NSMakeRange(3, 7)];
                        if (ws.passCarLince) {
                            [ZAActivityBar dismiss];
                            ws.passCarLince(linceSub);
                            [ws.navigationController popViewControllerAnimated:YES];
                        }
                    }else {
                        [ZAActivityBar showErrorWithStatus:LICENSE_REG_ERRO];
                        [weakScan setBtnEnabled:YES];
                        [ws startCamera];
                    }
                }else {
                    [ZAActivityBar showErrorWithStatus:LICENSE_REG_ERRO];
                    [weakScan setBtnEnabled:YES];
                    [ws startCamera];
                }
            }
        }];
    };
    [self.view addSubview:sv];//添加
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    float a = 720 / CGRectGetWidth([UIScreen mainScreen].bounds);
    float b = 1280 / CGRectGetHeight([UIScreen mainScreen].bounds);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    CGImageRef imagePartRef=CGImageCreateWithImageInRect(cgimg,CGRectMake((sv.leftWidth)*a,(sv.topHeight+10)*b, (sv.width)*a, (sv.height)*b));
    UIImage*cropImage=[UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return cropImage;
}

- (UIImage *)convertToGrayscale:(UIImage *)img {
    CGSize size = [img size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"扫描客户车辆";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    if ([_type isEqualToString:@"autowash"]) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(250, 0, 84, 44)];
        [rightBtn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"扫描清单" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)scanAction {
    ScanHistoryViewController *shvc = [[ScanHistoryViewController alloc] initWithNibName:@"ScanHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:shvc animated:YES];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)startCamera
{
    if (!_captureSession.running)
    {
        [_captureSession startRunning];
    }
}

- (void)stopCamera
{
    if (_captureSession.running)
    {
        [_captureSession stopRunning];
    }
}

- (void)showCamera:(void (^)(BOOL))complition
{
    _captureSession = [[AVCaptureSession alloc] init];
    
    // 设置采集的大小
    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    

    // ---------------- 添加 input - 输入设备 -  配置 device
    
    [self addCaputureDeviceInput];
    
    // ---------------- 添加 output - 输出设备 - 配置 device
    
    [self addCaputureDeviceOutput];
    
    // ---------------- 添加 添加到视图中 --
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    [self.view.layer addSublayer:_previewLayer];
    
    if (_captureDeviceInput)
    {
        [self startCamera];
        if (complition) {
            complition(YES);
        }
        
    }
}

- (void)captureImage:(void (^)(BOOL, UIImage *))cameraFinished
{
    //获取连接
    __block AVCaptureConnection * videoConnection = nil;
    
    [_captureOutput.connections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         AVCaptureConnection * connection = (AVCaptureConnection *)obj;
         
         [[connection inputPorts] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
          {
              AVCaptureInputPort * port = (AVCaptureInputPort *)obj;
              
              if ([[port mediaType] isEqualToString:AVMediaTypeVideo])
              {
                  videoConnection = connection;
                  *stop = YES;
              }
              
          }];
         
         if (videoConnection)
         {
             *stop = YES;
         }
         
     }];
    
    __block UIImage * image = nil;
    
    if (videoConnection)
    {
        //  -- 获取图片 - 为一个异步操作 --
        [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                    completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             
             [self stopCamera];
             
             @autoreleasepool
             {
                 NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 
                 image = [UIImage imageWithData:imageData];
                 
                 self.cameraImage = image;
                 
                 if (cameraFinished)
                 {
                     cameraFinished(YES,image);
                 }
                 
             }
         }];
    }
    
}

#pragma mark  ---------- Info ----------------

// input --
- (void)addCaputureDeviceInput
{
    _currentDevicePositon = AVCaptureDevicePositionBack; //后摄像头
    
    _captureDeviceInput = [self caputureDeviceInputWithPosition:_currentDevicePositon];
    
    if (_captureDeviceInput)
    {
        [_captureSession addInput:_captureDeviceInput];
    }
    else
    {
        [[[UIAlertView alloc]
           initWithTitle:nil
           message:@"打开设备失败"
           delegate:nil
           cancelButtonTitle:@"好"
           otherButtonTitles:nil, nil] show];
        
    }
}

// output --
- (void)addCaputureDeviceOutput
{
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    _captureOutput.outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     AVVideoCodecJPEG, AVVideoCodecKey,
                                     nil
                                     ];
    [_captureSession addOutput:_captureOutput];
}


//返回 input 设备 --
- (AVCaptureDeviceInput *)caputureDeviceInputWithPosition:(AVCaptureDevicePosition)position
{
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    __block AVCaptureDeviceInput * catureInput = nil;
    
    [devices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         AVCaptureDevice * device = (AVCaptureDevice *)obj;
         
         if (device.position == position)
         {
             NSError * error = nil;
             
             // -- 焦点 - 曝光 - 黑白色 -- 自动 --
             if ([device lockForConfiguration:&error]) {
                 if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                     device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                 if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                     device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                 if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
                     device.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
                 
                 [device unlockForConfiguration];
                 
             }
             catureInput = (AVCaptureDeviceInput *)[AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
         }
         
     }];
    
    return catureInput;
}

-(UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

- (UIImage*)grayscale:(UIImage*)anImage type:(int)type {
    
    CGImageRef imageRef = anImage.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
    
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            UInt8 *tmp;
            tmp = buffer + y * bytesPerRow + x * 4;
            
            UInt8 red,green,blue;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            
            UInt8 brightness;
            switch (type) {
                case 1:
                    brightness = (77 * red + 28 * green + 151 * blue) / 256;
                    *(tmp + 0) = brightness;
                    *(tmp + 1) = brightness;
                    *(tmp + 2) = brightness;
                    break;
                case 2:
                    *(tmp + 0) = red;
                    *(tmp + 1) = green * 0.7;
                    *(tmp + 2) = blue * 0.4;
                    break;
                case 3:
                    *(tmp + 0) = 255 - red;
                    *(tmp + 1) = 255 - green;
                    *(tmp + 2) = 255 - blue;
                    break;
                default:
                    *(tmp + 0) = red;
                    *(tmp + 1) = green;
                    *(tmp + 2) = blue;
                    break;
            }
        }
    }
    
    
    CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    
    CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    CGImageRef effectedCgImage = CGImageCreate(
                                               width, height,
                                               bitsPerComponent, bitsPerPixel, bytesPerRow,
                                               colorSpace, bitmapInfo, effectedDataProvider,
                                               NULL, shouldInterpolate, intent);
    
    UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    CGImageRelease(effectedCgImage);
    
    CFRelease(effectedDataProvider);
    
    CFRelease(effectedData);
    
    CFRelease(data);
    
    return effectedImage;
    
}

#pragma mark  ---------- request ----------------
- (void)addCarNum {
    if (lince.length > 0 && carImage) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSString *carNum = [lince substringWithRange:NSMakeRange(3, 7)];
        UIImage *newImg = [self convertToGrayscale:carImage];
        
        NSData *imgData = UIImageJPEGRepresentation(newImg, 0.2);
        NSString *imgBase64 = [imgData base64EncodedStringWithOptions:0];
        UIImageWriteToSavedPhotosAlbum(newImg, nil, nil, nil);
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = userInfo[@"UserId"];
        NSString *token = userInfo[@"Token"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSDictionary *parameters = @{@"CarNum":carNum,@"CarImage":imgBase64,@"UserToken":userDict};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddCarNum];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [[responseObject objectForKey:@"Code"] intValue];
            NSString *msg = @"";
            if (code == 0) {
                msg = @" 识别成功，请到车赢家系统自助洗车功能进行结算！";
            }else {
                msg = [NSString stringWithFormat:@" %@",responseObject[@"Message"]];
            }
            if (_autoWashResponse) {
                _autoWashResponse(msg);
            }
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
            NSLog(@"Error: %@", error);
        }];
    }else {
        [ZAActivityBar showErrorWithStatus:@"识别失败"];
    }
}

@end