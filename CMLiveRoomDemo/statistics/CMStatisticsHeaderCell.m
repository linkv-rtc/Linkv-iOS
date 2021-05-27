//
//  CMStatisticsHeaderCell.m
//  LinkV
//
//  Created by jfdreamyang on 2020/3/27.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMStatisticsHeaderCell.h"
#import "Masonry.h"

@interface CMStatisticsHeaderCell ()
@property (weak, nonatomic) IBOutlet UILabel *userIdLab;

@property (weak, nonatomic) IBOutlet UILabel *videoLostLab;
@property (weak, nonatomic) IBOutlet UILabel *audioLostLab;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLab;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateLab;

@property (weak, nonatomic) IBOutlet UILabel *videoRTT;
@property (weak, nonatomic) IBOutlet UILabel *videoFramerateLab;
@end

@implementation CMStatisticsHeaderCell

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

@end
