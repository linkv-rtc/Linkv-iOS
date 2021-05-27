//
//  CMSettingCell.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMSettingCell.h"

@interface CMSettingCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end


@implementation CMSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)reloadView:(NSDictionary *)info{
    NSArray *allKeys = info.allKeys;
    for (NSString *key in allKeys) {
        if (![key isEqualToString:@"type"]) {
            self.titleLab.text = key;
            self.contentLab.text = info[key];
            break;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
