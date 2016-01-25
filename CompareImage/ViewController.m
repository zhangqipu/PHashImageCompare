//
//  ViewController.m
//  CompareImage
//
//  Created by 张齐朴 on 15/12/3.
//  Copyright © 2015年 张齐朴. All rights reserved.
//

#import "ViewController.h"
#import "ImagePHash.h"
#import "ImagePickerViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableDictionary *pHashs;
    NSMutableArray *imageViews;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat w = CGRectGetWidth(self.view.bounds) / 2;
    
    NSArray *frames = @[[NSValue valueWithCGRect:CGRectMake(0, 0, w, w)],
                        [NSValue valueWithCGRect:CGRectMake(w, 0, w, w)],
                        [NSValue valueWithCGRect:CGRectMake(0, w, w, w)],
                        [NSValue valueWithCGRect:CGRectMake(w, w, w, w)]];
    pHashs = [NSMutableDictionary dictionary];
    imageViews = [NSMutableArray array];
    
    for (int i = 1; i < 5; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:[frames[i-1] CGRectValue]];
        imgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i.JPG", i]];
        [self.view addSubview:imgV];
        [imageViews addObject:imgV];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 20, 20)];
        label.tag = 999;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 10;
        label.text = [NSString stringWithFormat:@"%i", i];
        [imgV addSubview:label];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ImagePHash *imagePHash = [[ImagePHash alloc] init];
            NSString *pHashStr = [imagePHash getHashWithImage:imgV.image];
            NSLog(@"%@", pHashStr);
            [pHashs setObject:pHashStr forKey:[NSString stringWithFormat:@"%i", i]];
        });
    }
    
}

- (IBAction)takeImageAction:(id)sender {
    
    ImagePickerViewController *vc = [[ImagePickerViewController alloc] init];
    vc.pHashs = pHashs;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];

    
//    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
//    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
//    vc.delegate = self;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    UIImage *image = [UIImage imageNamed:@"3.jpg"];
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetWidth(self.view.bounds) , CGRectGetWidth(self.view.bounds) / 2, CGRectGetWidth(self.view.bounds) / 2)];
    
    imgV.image = image;
    
    [self.view addSubview:imgV];

    
    ImagePHash *imagePHash = [[ImagePHash alloc] init];
    NSString *pHashStr = [imagePHash getHashWithImage:image];
    NSLog(@"%@", pHashStr);
    
    __block int minDistance = INT_MAX;
    __block NSString *minKey = @"";
    [pHashs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        int distance = [ImagePHash distance:pHashStr betweenS2:obj];
        NSLog(@"%@ %@ %i", key, obj, distance);
        
        if (distance < minDistance) {
            minDistance = distance;
            minKey = key;
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self highlightedTheSameImageWithKey:minKey];
}

- (void)highlightedTheSameImageWithKey:(NSString *)key
{
    if ([key integerValue] > 0) {
        for (UIView *sv in [self.view subviews]) {
            if ([sv isKindOfClass:[UIImageView class]]) {
                UIImageView *imgV = (UIImageView *)sv;
                
                UILabel *label = [imgV viewWithTag:999];
                label.backgroundColor = [UIColor blackColor];
                if ([label.text isEqualToString:key]) {
                    label.backgroundColor = [UIColor redColor];
                    break;
                }
            }
        }
    }
}

//UIImage *image1 = [UIImage imageNamed:@"1"];
//UIImage *image2 = [UIImage imageNamed:@"33"];
//
//UIImageView *imageV1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) / 2)];
//UIImageView *imageV2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) / 2, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) / 2)];
//
//imageV1.image = image1;
//imageV2.image = image2;
//
//[self.view addSubview:imageV1];
//[self.view addSubview:imageV2];
//
//ImagePHash *hash1 = [[ImagePHash alloc] init];
//ImagePHash *hash2 = [[ImagePHash alloc] init];
//
//NSString *s1 = [hash1 getHashWithImage:image1];
//NSString *s2 = [hash2 getHashWithImage:image2];
//
//NSLog(@"\n%@\n%@", s1, s2);
//
//int distance = [ImagePHash distance:s1 betweenS2:s2];
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"结果：相似度%%%i", 100 - distance * 10] message:distance > 5 ? @"不相似" : @"相似" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
//
//#pragma clang diagnostic pop
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

