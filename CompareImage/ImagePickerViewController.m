//
//  ImagePickerViewController.m
//  CompareImage
//
//  Created by 张齐朴 on 15/12/5.
//  Copyright © 2015年 张齐朴. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ImagePHash.h"

@interface ImagePickerViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession          *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic, strong) AVCaptureVideoDataOutput  *videoOutPut;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupAVCapture];
    [self startRecognizing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_captureSession stopRunning];
}

- (void)setupAVCapture
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    NSError *err;
    if ([captureDevice lockForConfiguration:&err]) {
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
            captureDevice.flashMode = AVCaptureFlashModeOff;
        }
        
        [captureDevice unlockForConfiguration];
    }

    NSDictionary *imageOutPutSetting = @{AVVideoCodecKey : AVVideoCodecJPEG};
    _imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    _imageOutPut.outputSettings = imageOutPutSetting;
    
    NSDictionary *videoOutPutSetting = @{(__bridge id) kCVPixelBufferPixelFormatTypeKey :
                                             @(kCVPixelFormatType_32BGRA)};
    _videoOutPut = [[AVCaptureVideoDataOutput alloc] init];
    _videoOutPut.videoSettings = videoOutPutSetting;
    [_videoOutPut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:captureDeviceInput];
    [_captureSession addOutput:_imageOutPut];
    [_captureSession addOutput:_videoOutPut];
    [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto]; // quality of the output    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    self.imageView.image = uiImage;
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
}

- (void)startRecognizing
{
    __block BOOL isContinue = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (isContinue == YES) {
            if (_imageView.image == nil) continue;
            
            ImagePHash *imagePHash = [[ImagePHash alloc] init];
            NSString *pHashStr = [imagePHash getHashWithImage:_imageView.image];
            NSLog(@"%@", pHashStr);
            
            __block int minDistance = INT_MAX;
            __block NSString *minKey = @"";
            [_pHashs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                int distance = [ImagePHash distance:pHashStr betweenS2:obj];
                NSLog(@"%@ %@ %i", key, obj, distance);
                
                if (distance < 4) {
                    *stop = YES;
                    isContinue = NO;
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
                if (distance < minDistance) {
                    minDistance = distance;
                    minKey = key;
                }
            }];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
