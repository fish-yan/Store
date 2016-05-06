//
//  ScanningQRViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/7/17.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanningQRViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (copy, nonatomic) void(^passScanResult)(NSString *);
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end
