//
//  CMMacStatisticsCellView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMMacStatisticsCellView.h"
#import "Masonry.h"

@interface CMMacStatisticsCellView ()
@property (weak, nonatomic) IBOutlet NSTextField *userIdLab;

@property (weak, nonatomic) IBOutlet NSTextField *videoLostLab;
@property (weak, nonatomic) IBOutlet NSTextField *audioLostLab;

@property (weak, nonatomic) IBOutlet NSTextField *videoBitrateLab;
@property (weak, nonatomic) IBOutlet NSTextField *audioBitrateLab;

@property (weak, nonatomic) IBOutlet NSTextField *videoRTT;
@property (weak, nonatomic) IBOutlet NSTextField *videoFramerateLab;
@end

@implementation CMMacStatisticsCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)awakeFromNib{
//    CGFloat space = [UIScreen mainScreen].bounds.size.width/7;
    
    CGFloat space = 375/7.0;
    
    [self.userIdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.videoLostLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.audioLostLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 2));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.videoBitrateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 3));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.audioBitrateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 4));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.videoRTT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 5));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    [self.videoFramerateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 6));
        make.top.equalTo(self);
        make.width.equalTo(@(space));
        make.height.equalTo(self);
    }];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    for (NSInteger i=0; i<6; i++) {
        NSView *line = [[NSView alloc]init];
        line.wantsLayer = YES;
        line.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(space * (i+1)));
            make.width.equalTo(@1);
            make.height.equalTo(self);
            make.top.equalTo(self);
        }];
    }
    
    NSView *line = [[NSView alloc]init];
    line.wantsLayer = YES;
    line.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@1);
    }];
}

-(void)reloadView:(LVVideoStatistic *)statistics userId:(NSString *)userId{
    
    self.videoBitrateLab.stringValue = [NSString stringWithFormat:@"%d",statistics.videoBitratebps];
    self.audioBitrateLab.stringValue = [NSString stringWithFormat:@"%d",statistics.audioBitratebps];
    
    self.videoRTT.stringValue = [NSString stringWithFormat:@"%d/%d",statistics.videoRtt,statistics.audioRtt];
    self.videoFramerateLab.stringValue = [NSString stringWithFormat:@"%d",statistics.videoFps];
    
    self.videoLostLab.stringValue = [NSString stringWithFormat:@"%d",statistics.videoLostPercent];
    self.audioLostLab.stringValue = [NSString stringWithFormat:@"%d",statistics.audioLostPercent];
    self.userIdLab.stringValue = [NSString stringWithFormat:@"%@",[userId substringFromIndex:userId.length - 6]];
    
}


@end
