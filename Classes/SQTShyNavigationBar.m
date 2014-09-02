//
//  SQTShyNavigationBar.m
//  SQTShyNavigationBar
//
//  Created by Charles Powell on 8/30/14.
//  Copyright (c) 2014 Charles Powell. All rights reserved.
//

#import "SQTShyNavigationBar.h"

const CGFloat kSQTDefaultAnimationDuration = 0.2f;

@interface SQTShyNavigationBar () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) CGFloat zeroingOffset;

@end

@implementation SQTShyNavigationBar

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    // Set default config
    _enabled = YES;
    _shyHeight = 20.0f;
    _fullHeight = self.frame.size.height;
    _shouldSnap = YES;
    _zeroingOffset = 0.0f;
    
    // Create pan recognizer
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panRecognizer.delegate = self;
}

#pragma mark - External

- (void)setToFullHeight:(BOOL)animated {
    CGRect frame = self.frame;
    
    NSDictionary *locations = [self scrollLocationsForOffset:[self offsetOfScrollView:self.scrollView] frame:frame];
    CGFloat maximumLocation = [locations[@"maximum"] floatValue];
    
    frame.origin.y = maximumLocation;
    // Set this position as the zeroing offset
    self.zeroingOffset = [self offsetOfScrollView:self.scrollView];
    
    // Set frame
    [self moveToFrame:frame animated:animated];
}

- (void)setToShyHeight:(BOOL)animated {
    if (self.shouldSnap) {
        [self snapForCurrentLocation];
    } else {
        [self adjustLocationForOffset:[self offsetOfScrollView:self.scrollView] duration:@(0.0f)];
    }
}

- (void)prepareForSegueAway:(BOOL)animated {
    [self setToFullHeight:animated];
    self.enabled = NO;
}

- (void)prepareForSegueBack:(BOOL)animated {
    [self setToShyHeight:animated];
    self.enabled = YES;
}

#pragma mark - Scrolling/Panning

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update secret reference to scrollView
    self.scrollView = scrollView;
    
    // Stop if disabled
    if (!self.enabled) {
        return;
    }
    
    // Update for scrollView position
    [self adjustLocationForOffset:[self offsetOfScrollView:scrollView]];
}

- (void)adjustLocation {
    if (!self.scrollView) {
        return;
    }
    [self adjustLocationForOffset:[self offsetOfScrollView:self.scrollView]];
}

- (void)adjustLocationForOffset:(CGFloat)offset {
    [self adjustLocationForOffset:offset duration:nil];
}

- (void)adjustLocationForOffset:(CGFloat)offset duration:(NSNumber *)duration {
    CGRect frame = self.frame;
    
    NSDictionary *locations = [self scrollLocationsForOffset:offset frame:frame];
    CGFloat minimumLocation = [locations[@"minimum"] floatValue];
    CGFloat maximumLocation = [locations[@"maximum"] floatValue];
    CGFloat originY = [locations[@"originY"] floatValue];
    CGFloat offsetOriginY = [locations[@"offsetOriginY"] floatValue];
    
    CGFloat trueFraction = (originY - minimumLocation)/(maximumLocation - minimumLocation);
    CGFloat offsetFraction = (offsetOriginY - minimumLocation)/(maximumLocation - minimumLocation);
    if (offsetFraction == 0.0f || offsetFraction == 1.0f) {
        // Reset zeroing offset
        self.zeroingOffset = 0.0f;
    } else {
        originY = offsetOriginY;
    }
    
    // Bound originY for safety
    originY = MAX(MIN(maximumLocation, originY), minimumLocation);
    
    // Use error to adjust animation speed if not specified
    CGFloat animDuration = fabs(originY - frame.origin.y)/1000.0f;
    if (duration) {
        animDuration = duration.floatValue;
    }
    
    frame.origin.y = originY;
    [self moveToFrame:frame duration:animDuration];
    
    if (self.shouldSnap && self.scrollView.decelerating && !self.scrollView.tracking) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (self.shouldSnap && !self.scrollView.decelerating && !self.scrollView.tracking) {
                if (trueFraction > 0.0f && trueFraction < 1.0f) {
                    [self snapForCurrentLocation];
                }
            }
        });
    }
}

- (void)snapForCurrentLocation {
    if (!self.scrollView) {
        return;
    }
    [self snapToLocationForFrame:self.frame offset:[self offsetOfScrollView:self.scrollView]];
}

- (void)snapToLocationForFrame:(CGRect)frame offset:(CGFloat)offset {
    if (!self.enabled) {
        return;
    }
    NSDictionary *locations = [self scrollLocationsForOffset:offset frame:frame];
    CGFloat minimumLocation = [locations[@"minimum"] floatValue];
    CGFloat maximumLocation = [locations[@"maximum"] floatValue];
    CGFloat originY = [locations[@"originY"] floatValue];
    CGFloat fraction = (originY - minimumLocation)/(maximumLocation - minimumLocation);
    if (fraction == 1.0f) {
        return;
    } else if (fraction > 0.0f) {
        // Scroll is not at minimum position, snap back to max
        originY = maximumLocation;
        // Set this position as the zeroing offset
        self.zeroingOffset = [self offsetOfScrollView:self.scrollView];
    } else {
        // Fraction is zero, snap to min
        originY = minimumLocation;
        // Reset zeroing offset
        self.zeroingOffset = 0.0f;
    }
    
    // Bound originY for safety
    originY = MAX(MIN(maximumLocation, originY), minimumLocation);
    frame.origin.y = originY;
    
    [self moveToFrame:frame];
}

- (void)moveToFrame:(CGRect)frame {
    [self moveToFrame:frame animated:YES];
}

- (void)moveToFrame:(CGRect)frame animated:(BOOL)animated {
    [self moveToFrame:frame duration:(animated ? kSQTDefaultAnimationDuration : 0.0f)];
}

- (void)moveToFrame:(CGRect)frame duration:(CGFloat)duration {
    // Enclose changes
    void(^moveBlock)(void) = ^(void) {
        // Adjust insets
        UIEdgeInsets inset = self.scrollView.contentInset;
        CGFloat statusBarHeight = [self defaultLocation];
        inset.top = MAX(MIN(self.fullHeight + statusBarHeight, frame.origin.y + frame.size.height), self.shyHeight);
        self.scrollView.contentInset = inset;
        // Adjust frame
        self.frame = frame;
    };
    
    if (duration > 0.0f) {
        [UIView animateWithDuration:duration
                         animations:moveBlock];
    } else {
        moveBlock();
    }
}

- (CGFloat)offsetOfScrollView:(UIScrollView *)scrollView {
    return self.fullHeight + [self defaultLocation] + scrollView.contentOffset.y;
}

- (NSDictionary *)scrollLocationsForOffset:(CGFloat)offset frame:(CGRect)frame {
    CGFloat defaultLocation = [self defaultLocation];
    
    CGFloat minimumLocation = self.shyHeight - frame.size.height;
    CGFloat maximumLocation = defaultLocation;
    
    CGFloat originY = MAX(MIN(maximumLocation, defaultLocation - offset), minimumLocation);
    CGFloat offsetOriginY = MAX(MIN(maximumLocation, defaultLocation - offset + self.zeroingOffset), minimumLocation);
    
    NSDictionary *locations = @{@"minimum" : @(minimumLocation),
                                @"maximum" : @(maximumLocation),
                                @"originY" : @(originY),
                                @"offsetOriginY" : @(offsetOriginY)};
    return locations;
}

#pragma mark - Pan Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // Stop if disabled
    if (!self.enabled) {
        return;
    }
    
    if ((recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) &&
             !self.scrollView.decelerating && self.shouldSnap) {
        [self snapForCurrentLocation];
    }
}

#pragma mark - Frame Management

- (CGFloat)defaultLocation {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return [UIApplication sharedApplication].statusBarFrame.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return 0.0f;
            break;
        default:
            return 20.0f;
            break;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = [super sizeThatFits:size];
    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
    newSize.height = self.fullHeight;
    return newSize;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setCenter:(CGPoint)center {
    // Set center to make subviews happy
    [super setCenter:center];
    
    // Immediately readjust
    [self adjustLocation];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.enabled) {
        [self adjustLocationForOffset:[self offsetOfScrollView:self.scrollView] duration:@(kSQTDefaultAnimationDuration)];
    }
}

#pragma mark - Custom Getters/Setters

- (void)setScrollView:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        return;
    }
    
    _scrollView = scrollView;
    [self.panRecognizer.view removeGestureRecognizer:self.panRecognizer];
    [_scrollView addGestureRecognizer:self.panRecognizer];
}

@end


#pragma mark - Support

@implementation UINavigationController (SQTShyNavigationBar)

- (SQTShyNavigationBar *)shyNavigationBar {
    UINavigationBar *navBar = self.navigationBar;
    if ([navBar isKindOfClass:[SQTShyNavigationBar class]]) {
        return (SQTShyNavigationBar *)navBar;
    }
    
    return nil;
}

@end
