//
//  RMEditorViewController.h
//  RingtoneMaker
//
//  Created by Sandeep Nasa on 2/19/13.
//  Copyright (c) 2013 Pawan Rai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "RangeSlider.h"

@interface RMEditorViewController : UIViewController<MPMediaPickerControllerDelegate>{

    NSString * _sliderRangeText;
    
}
@property(strong, nonatomic) NSURL *playUrl;
@end
