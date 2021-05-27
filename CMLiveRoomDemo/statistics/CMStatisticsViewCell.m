//
//  CMStatisticsViewCell.m
//  LinkV
//
//  Created by jfdreamyang on 2020/3/27.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMStatisticsViewCell.h"
#import "Masonry.h"

@interface CMStatisticsViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *userIdLab;

@property (weak, nonatomic) IBOutlet UILabel *videoLostLab;
@property (weak, nonatomic) IBOutlet UILabel *audioLostLab;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLab;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateLab;

@property (weak, nonatomic) IBOutlet UILabel *videoRTT;
@property (weak, nonatomic) IBOutlet UILabel *videoFramerateLab;
@end


@implementation CMStatisticsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    CGFloat space = [UIScreen mainScreen].bounds.size.width/7;
    
    [self.userIdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.videoLostLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.audioLostLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 2));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.videoBitrateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 3));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.audioBitrateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 4));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.videoRTT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 5));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    [self.videoFramerateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(space * 6));
        make.top.equalTo(self.contentView);
        make.width.equalTo(@(space));
        make.height.equalTo(self.contentView);
    }];
    
    self.backgroundColor = [UIColor clearColor];
    
    for (NSInteger i=0; i<6; i++) {
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(space * (i+1)));
            make.width.equalTo(@1);
            make.height.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)reloadView:(LVVideoStatistic *)statistics userId:(NSString *)userId{
    
    self.videoBitrateLab.text = [NSString stringWithFormat:@"%d",statistics.videoBitratebps];
    self.audioBitrateLab.text = [NSString stringWithFormat:@"%d",statistics.audioBitratebps];
    
    self.videoRTT.text = [NSString stringWithFormat:@"%d/%d",statistics.videoRtt,statistics.audioRtt];
    self.videoFramerateLab.text = [NSString stringWithFormat:@"%d",statistics.videoFps];
    
    self.videoLostLab.text = [NSString stringWithFormat:@"%d",statistics.videoLostPercent];
    self.audioLostLab.text = [NSString stringWithFormat:@"%d",statistics.audioLostPercent];
    if (userId.length >= 12) {
        self.userIdLab.text = [NSString stringWithFormat:@"%@",[userId substringFromIndex:userId.length - 6]];
    }
    else{
        self.userIdLab.text = userId;
    }
}

@end
