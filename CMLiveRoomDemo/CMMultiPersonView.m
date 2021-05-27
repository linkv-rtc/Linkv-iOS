//
//  CMMultiPersonView.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMMultiPersonView.h"

@interface CMMultiPersonView ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation CMMultiPersonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataSource = [NSMutableArray new];
        
        CGFloat width = self.frame.size.width;
        CGFloat space = 2;
        CGFloat cellWidth = (width - 4 * space)/3;
        CGFloat cellHeight = cellWidth;
        CGFloat originY = self.frame.size.height / 2 - (cellHeight * 3 - 10)/2;
        
        for (NSInteger i=0; i<9; i++) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(space * (i%3) + space + cellWidth * (i%3) , space * (i/3) + space + cellHeight * (i/3) + originY, cellWidth, cellHeight)];
            [self addSubview:view];
            view.backgroundColor = [UIColor colorWithRed:50/255.f green:45/255.f blue:62/255.f alpha:1.f];
            view.tag = 10000 + i;
            
            UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 56, 56)];
            bgView.center = CGPointMake(cellWidth/2, cellHeight/2);
            [view addSubview:bgView];
            [self.dataSource addObject:view];
        }
    }
    return self;
}

-(void)reloadData:(NSArray *)dataSource{
    for (LVRTCDisplayView *displayView in dataSource) {
        BOOL contain = NO;
        for (UIView *view in self.dataSource) {
            for (UIView *old in view.subviews) {
                if (old == displayView) {
                    contain = YES;
                    break;
                }
            }
            if (contain) {
                break;
            }
        }
        if (!contain) {
            NSInteger index = [self findFirstIdleView];
            UIView *view = [self viewWithTag:index];
            displayView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            [view insertSubview:displayView atIndex:0];
        }
    }
}

-(NSInteger)findFirstIdleView{
    for (UIView *view in self.dataSource) {
        BOOL find = NO;
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[LVRTCDisplayView class]]) {
                find = YES;
            }
        }
        if (!find) {
            return view.tag;
        }
    }
    return 0;
}

@end
