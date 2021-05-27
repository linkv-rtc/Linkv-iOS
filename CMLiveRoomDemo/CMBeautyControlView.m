//
//  CMBeautyControlView.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/24.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMBeautyControlView.h"

@interface CMBeautyControlView ()
@property (weak, nonatomic) IBOutlet UISlider *beautySlider;
@property (weak, nonatomic) IBOutlet UISlider *toneSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightSlider;

@end

@implementation CMBeautyControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)beautyLevel:(UISlider *)sender {
    [self.delegate setBeautyLevel:sender.value];
}
- (IBAction)brightLevel:(UISlider *)sender {
    [self.delegate setBrightLevel:sender.value];
}
- (IBAction)toneLevel:(UISlider *)sender {
    [self.delegate setToneLevel:sender.value];
}
- (IBAction)hideControlView:(id)sender {
    [self.delegate hideBeautyControlView];
}

-(void)reset{
    self.beautySlider.value = 0.5;
    self.brightSlider.value = 0.5;
    self.toneSlider.value = 0.5;
}

@end
