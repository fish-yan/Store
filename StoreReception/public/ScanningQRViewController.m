//
//  ScanningQRViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/17.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ScanningQRViewController.h"
#import "ScanningView.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ScanningQRViewController () {
    ScanningView *hahaview;
}

@end

@implementation ScanningQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        [self setupCamera];
    }
    WS(ws);
    hahaview = [[ScanningView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds))];//初始化、坐标
    hahaview.backgroundColor = [UIColor clearColor];//要透明的
    hahaview.funType = QRCODE;
    hahaview.cancelClick = ^(void){
        [ws dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    [self.view addSubview:hahaview];//添加
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode39Mod43Code];
    CGSize size = self.view.bounds.size;
    float leftWidth = 50;
    float width = CGRectGetWidth(self.view.frame) - leftWidth * 2;
    float height = width;
    float topHeight = (CGRectGetHeight(self.view.frame) - height - 150) / 2;
    CGRect cropRect = CGRectMake(leftWidth, topHeight, width, height);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                  cropRect.origin.x/size.width,
                                                  cropRect.size.height/fixHeight,
                                                  cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                  (cropRect.origin.x + fixPadding)/fixWidth,
                                                  cropRect.size.height/size.height,
                                                  cropRect.size.width/fixWidth);
    }
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.frame;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    
    
    // Start
    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
        [self dismissViewControllerAnimated:YES completion:^
         {
             [hahaview.timer invalidate];
             if (_passScanResult) {
                 _passScanResult(stringValue);
             }
             NSLog(@"%@",stringValue);
         }];
}


@end
