//
//  SBSliderView.h
//  ImageSlider
//
//  Created by Soumalya Banerjee on 22/07/15.
//  Copyright (c) 2015 Soumalya Banerjee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIView+WebCache.h>
@class SBSliderDelegate;
@class imageProfileClass;

@protocol SBSliderDelegate <NSObject>

@optional
//- (void)sbslider:(SBSliderDelegate *)sbslider didTapOnImage:(UIImage *)targetImage andParentView:(UIImageView *)targetView;
//- (void)sliderlastindex : (NSString *)lastindex :(NSString *)Sectiontag;

@end

@interface SBSliderView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    id <SBSliderDelegate>_delegate;
    
}

@property (nonatomic, strong) id <SBSliderDelegate>delegate;
@property (nonatomic, strong) IBOutlet UIScrollView *sliderMainScroller;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (strong, nonatomic) IBOutlet UILabel *lblpagecount;
//@property (nonatomic) BOOL is_checklaberorimage;
@property (strong, nonatomic) IBOutlet UIImageView *imageview;

//@property (nonatomic) UIImage * tintcolorimage;
@property (nonatomic) int currentpostion;

- (void)createSliderWithImages:(NSArray *)image title:(NSArray *)title WithAutoScroll:(BOOL)isAutoScrollEnabled inView:(UIView *)parentView;

-(void)startAutoPlay;
-(void)stopAutoPlay;
- (void)slideImage;
- (void)backslideImage;
@end
