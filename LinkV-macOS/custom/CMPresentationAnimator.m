//
//  CMPresentationAnimator.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMPresentationAnimator.h"
#import "Masonry.h"

@implementation CMPresentationAnimator

-(void)animatePresentationOfViewController:(NSViewController *)viewController fromViewController:(NSViewController *)fromViewController{
    
    NSView *containerView = fromViewController.view;
    
    NSView *modalView = viewController.view;
    
    [containerView addSubview:modalView];
    
    NSRect frame = fromViewController.view.bounds;
    frame.origin.y = -frame.size.height;
    modalView.frame = frame;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.5;
        NSRect framet = fromViewController.view.bounds;
        modalView.animator.frame = framet;
    } completionHandler:^{
        [modalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(containerView);
        }];
    }];
}

-(void)animateDismissalOfViewController:(NSViewController *)viewController fromViewController:(NSViewController *)fromViewController{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
       
        context.duration = 0.2;
        viewController.view.animator.alphaValue = 0;
        
    } completionHandler:^{
        [viewController.view removeFromSuperview];
    }];
    
}

@end
