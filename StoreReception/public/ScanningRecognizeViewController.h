//
//  ScanningRecognizeViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/7/20.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanningRecognizeViewController : UIViewController {
    AVCaptureSession * _captureSession;
    AVCaptureDeviceInput  * _captureDeviceInput;
    AVCaptureStillImageOutput * _captureOutput;
    AVCaptureVideoPreviewLayer * _previewLayer;
    AVCaptureDevicePosition _currentDevicePositon;
}

@property (nonatomic,retain) UIImage * cameraImage;
@property (nonatomic,retain) NSString *type;
@property (copy, nonatomic) void (^passCarLince)(NSString *);
@property (copy, nonatomic) void (^cancelClick)(void);
@property (copy, nonatomic) void (^autoWashResponse)(NSString *);

@end
