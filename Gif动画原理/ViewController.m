//
//  ViewController.m
//  Gif动画原理
//
//  Created by ZT0526 on 2017/2/28.
//  Copyright © 2017年 ZT. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import "ZTTestProxy.h"
@interface ViewController (){
    CGImageSourceRef _source;
    NSData           *_data;
    NSInteger        _frameCount;
    NSInteger        _loopCount;
    NSMutableArray   *_frames;
    NSMutableArray   *_delays;
    UIImageOrientation _orientation;
    NSInteger        currentIndex;
    NSTimeInterval   duration;
    NSTimeInterval   _time;
    CADisplayLink   *_link;
}

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @autoreleasepool {
        
        [self _configsubViews];
        
    }
}

-(void)_configsubViews{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview: self.imageView];
    
    [self _getImages];
    
    const NSTimeInterval kDisplayRefreshRate = 60.0; // 60Hz
    
    //__weak typeof(self) weakSelf = self;
    _link = [CADisplayLink displayLinkWithTarget:[[ZTTestProxy alloc] initWithTarget:self] selector:@selector(_setImage:)];
    //link.frameInterval = duration * 60;
    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)_getImages{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"niconiconi@2x" ofType:@"gif"];//niconiconi@2x
    _data = [NSData dataWithContentsOfFile:path];
    _source = CGImageSourceCreateWithData((__bridge CFDataRef)_data, NULL);
    CFDictionaryRef properties = CGImageSourceCopyProperties(_source, NULL);
    if (properties) {
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) CFNumberGetValue(loop, kCFNumberNSIntegerType, &_loopCount);
        }
        CFRelease(properties);
    }
    _frameCount = CGImageSourceGetCount(_source);//获取image source里面的图片数量
    
    _frames = [NSMutableArray new];
    _delays = [NSMutableArray new];
    for (NSUInteger i = 0; i < _frameCount; i++) {
        
        
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_source, i, NULL);
        if (properties) {
            NSInteger orientationValue = 0, width = 0, height = 0;
            CFTypeRef value = NULL;
            
            value = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            if (value) CFNumberGetValue(value, kCFNumberNSIntegerType, &width);
            value = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            if (value) CFNumberGetValue(value, kCFNumberNSIntegerType, &height);
            //            if (_type == YYImageTypeGIF) {
            CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            if (gif) {
                // Use the unclamped frame delay if it exists.
                value = CFDictionaryGetValue(gif, kCGImagePropertyGIFUnclampedDelayTime);
                if (!value) {
                    // Fall back to the clamped frame delay if the unclamped frame delay does not exist.
                    value = CFDictionaryGetValue(gif, kCGImagePropertyGIFDelayTime);
                }
                if (value) CFNumberGetValue(value, kCFNumberDoubleType, &duration);
                [_delays addObject:@(duration)];
            }
            //}
            
            //            frame.width = width;
            //            frame.height = height;
            //            frame.duration = duration;
            NSLog(@"this is duration: %f",duration);
            
            value = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (value) {
                CFNumberGetValue(value, kCFNumberNSIntegerType, &orientationValue);
                _orientation = ZTUIImageOrientationFromEXIFValue(orientationValue);
            }
            
            
            //            [frames addObject:frame];
            
            CFRelease(properties);
            
        }
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_source, i, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:1 orientation:_orientation];
        [_frames addObject:image];
    }
    if (duration < 0.011f) duration = 0.100f;
}

- (void)_setImage:(CADisplayLink *)link{
    
    NSTimeInterval delay = 0;
    _time += link.duration;
    delay = [[_delays objectAtIndex:currentIndex] doubleValue];
    if (_time < delay){
        return;
    }
    _time -= delay;
    
    UIImage *image = _frames[currentIndex];
    self.imageView.layer.contents = nil;
    self.imageView.layer.contents = (__bridge id _Nullable)(image.CGImage);
    NSLog(@"current index:%ld ",(long)currentIndex);
    currentIndex++;
    if(currentIndex >= _frames.count) currentIndex = 0;
}

- (void)dealloc{
    [_link invalidate];
    _link = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

UIImageOrientation ZTUIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}


-(UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor greenColor];
    }
    
    return _imageView;
}


@end
