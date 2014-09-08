//
//  SQTShyNavigationBar.h
//  SQTShyNavigationBar
//
//  Created by Charles Powell on 8/30/14.
//  Copyright (c) 2014 Charles Powell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQTShyNavigationBar : UINavigationBar

// Characteristics
@property (nonatomic) CGFloat shyHeight;
@property (nonatomic) CGFloat fullHeight;
@property (nonatomic) BOOL shouldSnap;

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL settled;

@property (nonatomic, copy) void (^updateBlock)(CGRect visibleFrame, CGFloat shyFraction, NSArray *subviews);

// Feedback
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

// Handlers
- (void)setToFullHeight:(BOOL)animated;
- (void)setToShyHeight:(BOOL)animated;

// Navigation Management
- (void)prepareForSegueAway:(BOOL)animated;
- (void)adjustForSequeInto:(BOOL)animated;
- (void)adjustForSequeInto:(BOOL)animated scrollView:(UIScrollView *)scrollView;


@end


@interface UINavigationController (SQTShyNavigationBar)

@property (nonatomic, readonly) SQTShyNavigationBar *shyNavigationBar;

@end
