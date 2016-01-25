//
//  ImagePickerViewController.h
//  CompareImage
//
//  Created by 张齐朴 on 15/12/5.
//  Copyright © 2015年 张齐朴. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSDictionary *pHashs;

@end
