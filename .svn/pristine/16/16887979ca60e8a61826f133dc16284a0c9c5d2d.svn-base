#import "PlateRecognize.h"
#import "UIImage+fixOrientation.h"
#include "plate_recognize.h"
using namespace easypr;


@interface PlateRecognize ()
@property ( nonatomic)CPlateRecognize pr;

- (instancetype)init;

@end


@implementation PlateRecognize

static PlateRecognize *plateREcognizeInstance = nil;

+ (instancetype)sharedPlateRecognize {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        plateREcognizeInstance = [[self alloc] init];
    });
    return plateREcognizeInstance;
}

- (instancetype)init {
    self = [super init];
    NSString *ann_ns=[[NSBundle mainBundle]pathForResource:@"ann" ofType:@"xml"];
    NSString *svm_ns=[[NSBundle mainBundle]pathForResource:@"svm" ofType:@"xml"];
    string annpath=[ann_ns UTF8String];
    string svmpath=[svm_ns UTF8String];
    self.pr.LoadANN(annpath);
    self.pr.LoadSVM(svmpath);
    
    self.pr.setLifemode(true);
    self.pr.setDebug(false);
    return self;
}

- (NSMutableArray *)recognizeFromImage:(UIImage *)image outImages:(NSMutableArray*) resultImage {
    UIImage *portraitImage = [image fixOrientation];
    cv::Mat source_image = [self cvMatFromUIImage:portraitImage];
    resize(source_image, source_image,cv::Size(source_image.cols/2,source_image.rows/2));
    vector<string> plateVec;
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    vector<cv::Mat> resultPlate;
    int result = self.pr.plateRecognize(source_image, plateVec, resultPlate);
    if (result == 0) {
        if (resultImage == nil) {
            return nil;
        }
        for (int i = 0; i < resultPlate.size(); ++i) {
            [resultImage addObject:[self UIImageFromCVMat:resultPlate[i]]];
        }
    }
    if (result == 0) {
        if (plateVec.size() > 0) {
            for (int i = 0; i < plateVec.size(); ++i) {
                [resultArray addObject:[NSString stringWithCString:plateVec[i].c_str() encoding:NSUTF8StringEncoding]];
            }
        }
    }
    return resultArray;
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    cv::Mat cvMatRGB;
    cv::cvtColor(cvMat, cvMatRGB, CV_RGBA2RGB);
    
    return cvMatRGB;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end