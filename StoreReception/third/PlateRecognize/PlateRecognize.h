#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

@interface PlateRecognize : NSObject

+ (instancetype)sharedPlateRecognize;

- (NSMutableArray *)recognizeFromImage:(UIImage *)image outImages:(NSMutableArray*) resultImage;

@end