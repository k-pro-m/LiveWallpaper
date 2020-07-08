//
//  SBSliderView.m
//  ImageSlider
//
//  Created by Soumalya Banerjee on 22/07/15.
//  Copyright (c) 2015 Soumalya Banerjee. All rights reserved.
//

#import "SBSliderView.h"

@implementation SBSliderView {
    NSArray *imagesArray;
    NSArray *titleArray;
    BOOL autoSrcollEnabled;
    
    NSTimer *activeTimer;
    CGFloat screenwidth ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//    }
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if(self) {
//        [self setup];
//    }
//    return self;
//}
//
//- (void)setup {
//    [[NSBundle mainBundle] loadNibNamed:@"SBSliderView" owner:self options:nil];
////    [self addSubview:self.view];
//}

#pragma mark - Create Slider with images
- (void)createSliderWithImages:(NSArray *)image title:(NSArray *)title WithAutoScroll:(BOOL)isAutoScrollEnabled inView:(UIView *)parentView{
    screenwidth = [UIScreen mainScreen].bounds.size.width;
//- (void)createSliderWithImages:(NSArray *)images WithAutoScroll:(BOOL)isAutoScrollEnabled inView:(UIView *)parentView {
//    self.backgroundColor = [UIColor blackColor];
//    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.frame = CGRectMake(0, 0, screenwidth, self.bounds.size.height);
    self.lblpagecount.frame = CGRectMake(self.center.x,self.center.y, self.lblpagecount.frame.size.width, self.lblpagecount.frame.size.height);
    
//    _sliderMainScroller = [[UIScrollView alloc]init];
    titleArray = [NSArray arrayWithArray:title];
    imagesArray = [NSArray arrayWithArray:image];
    autoSrcollEnabled = isAutoScrollEnabled;

    _sliderMainScroller.pagingEnabled = YES;
    _sliderMainScroller.delegate = self;
    _pageIndicator.numberOfPages = [imagesArray count];
    

    if (imagesArray.count > 1) {
        
        _sliderMainScroller.contentSize = CGSizeMake((screenwidth * [imagesArray count] * 3), self.bounds.size.height);
    }
    else
    {
        _sliderMainScroller.contentSize = CGSizeMake((screenwidth * [imagesArray count] ), self.bounds.size.height);
    }
    
    
    int mainCount = 0;
    for (int x = 0; x < 3; x++) {
    
        for (int i=0; i < [imagesArray count]; i++) {
            
//            if (self.is_checklaberorimage == true) {
                [self.lblpagecount setHidden:YES];
                [self.pageIndicator setHidden:NO];
                
                NSString *label = titleArray[i];
                UILabel *lbl = [[UILabel alloc] init];
                CGRect frameRect;
                frameRect.origin.y = _imageview.frame.size.height - 17.0;//_lblpagecount.frame.origin.y;
            frameRect.size.width = screenwidth;
                frameRect.size.height = _lblpagecount.frame.size.height;//_sliderMainScroller.frame.size.height/3;
                frameRect.origin.x = (frameRect.size.width * mainCount);
                lbl.frame = frameRect;
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.textColor = [UIColor whiteColor];
//            [lbl setBackgroundColor:[UIColor brownColor]];
                lbl.text = label;
                [lbl setFont:[UIFont systemFontOfSize:18.0]];
//Helvetica-Bold
//
                //            [UIImage imageNamed:(NSString *)
                [_sliderMainScroller addSubview:lbl];
            

            
//                lbl.clipsToBounds = YES;
//                lbl.userInteractionEnabled = YES;
//
//                UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage:)];
//                tapOnImage.delegate = self;
//                tapOnImage.numberOfTapsRequired = 1;
//                [lbl addGestureRecognizer:tapOnImage];
//
//
//                mainCount++;
                
//            }
//            else
//            {
//                [self.lblpagecount setHidden:NO];
//                [self.pageIndicator setHidden:YES];
                NSString *nameimg = imagesArray[i];
                UIImageView *imageV = [[UIImageView alloc] init];
                frameRect.origin.y = _imageview.frame.origin.y;//0.0f;
                frameRect.size.width = screenwidth;
                frameRect.size.height = _imageview.frame.size.height - 25.0;//_sliderMainScroller.frame.size.height;
                frameRect.origin.x = (frameRect.size.width * mainCount);
                imageV.frame = frameRect;
//                [imageV setBackgroundColor:[UIColor redColor]];
                [imageV setClipsToBounds:YES];
                imageV.contentMode = UIViewContentModeScaleAspectFit;
                //            imageV.image = [imagesArray objectAtIndex:i];
                
//                imageV.sd_imageIndicator = SDWebImageActivityIndicator.grayIndicator;
//                [imageV.sd_imageIndicator startAnimatingIndicator];
            
                imageV.image = [UIImage imageNamed:nameimg];
//                [imageV sd_setShowActivityIndicatorView:YES];
//
//                [imageV sd_setShowActivityIndicatorView:UIActivityIndicatorViewStyleGray];
                

//                [imageV sd_setImageWithURL:url  placeholderImage:[UIImage imageNamed:@"Background_HD"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//                    if (!error && image) {
//                        imageV.image = image;
//                        //                    [weakSelf drawImage];
//                    } else {
//                        //                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
//                        //                    style.messageAlignment = NSTextAlignmentCenter;
//                        //                    [weakSelf makeToast:[ZMImageSliderUtility localizedString:@"Failed to load the image"] duration:2 position:CSToastPositionCenter style:style];
//                        //
//                        //            [self addvideobtn];
//                    }
////                    [imageV sd_setShowActivityIndicatorView:NO];
//                    [imageV.sd_imageIndicator stopAnimatingIndicator];
//
//                }];
                //            [UIImage imageNamed:(NSString *)
                [_sliderMainScroller addSubview:imageV];
                imageV.clipsToBounds = YES;
                imageV.userInteractionEnabled = YES;
                
//                UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage:)];
//                tapOnImage.delegate = self;
//                tapOnImage.numberOfTapsRequired = 1;
//                [imageV addGestureRecognizer:tapOnImage];
//                
                
                mainCount++;
                
            }
            
            
//        }
        
//        if (_currentpostion != nil &&  self.is_checklaberorimage == true) {
//            _pageIndicator.currentPage = _currentpostion ;
//        }
//    
    }
    
    CGFloat startX = (CGFloat)[imagesArray count] * screenwidth;
    [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
    
    if (([imagesArray count] > 1) && (isAutoScrollEnabled)) {
        [self startTimerThread];
    }
    [self bringSubviewToFront:self.lblpagecount];
    [self.lblpagecount bringSubviewToFront:self];
    
   
    _lblpagecount.text = [NSString stringWithFormat:@"1/%lu",(unsigned long)imagesArray.count];
}

#pragma mark end -


#pragma mark - GestureRecognizer delegate

- (void)tapOnImage:(UITapGestureRecognizer *)gesture {
    
//    UIImageView *targetView = (UIImageView *)gesture.view;
//    [_delegate sbslider:self didTapOnImage:targetView.image andParentView:targetView];
    
}

#pragma mark end -

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger moveToPage = page;
    if (moveToPage == 0) {
        if ([imagesArray count] > 1) {
            
            
        moveToPage = [imagesArray count];
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [scrollView setContentOffset:CGPointMake(startX, 0) animated:NO];
        }
        
    } else if (moveToPage == (([imagesArray count] * 3) - 1)) {
        if ([imagesArray count] > 1) {
            
       
        moveToPage = [imagesArray count] - 1;
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [scrollView setContentOffset:CGPointMake(startX, 0) animated:NO];
        }
        
    }
    
    if (moveToPage < [imagesArray count]) {
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    } else {
        
        moveToPage = moveToPage % [imagesArray count];
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    }
    if (([imagesArray count] > 1) && (autoSrcollEnabled)) {
        [self startTimerThread];
    }
    
    
//      [_delegate sliderlastindex:[NSString stringWithFormat:@"%ld",(long)_pageIndicator.currentPage]:[NSString stringWithFormat:@"%ld",(long)self.tag]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger moveToPage = page;
    if (moveToPage == 0) {
        
        moveToPage = [imagesArray count];
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [scrollView setContentOffset:CGPointMake(startX, 0) animated:NO];
        
    } else if (moveToPage == (([imagesArray count] * 3) - 1)) {
        
        moveToPage = [imagesArray count] - 1;
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [scrollView setContentOffset:CGPointMake(startX, 0) animated:NO];
        
    }
    
    if (moveToPage < [imagesArray count]) {
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    } else {
        
        moveToPage = moveToPage % [imagesArray count];
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    }
    
   
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (activeTimer) {
        [activeTimer invalidate];
        activeTimer = nil;
    }
    
//    if (_pageIndicator.currentPage == [imagesArray count]-1) {
   
//    }
}

-(void)withoutScrollviewchangesValues
{
    CGFloat width = _sliderMainScroller.frame.size.width;
    NSInteger page = (_sliderMainScroller.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger moveToPage = page;
    if (moveToPage == 0) {
        if ([imagesArray count] > 1) {
            
            
            moveToPage = [imagesArray count];
            CGFloat startX = (CGFloat)moveToPage * screenwidth;
            [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
        }
        
    } else if (moveToPage == (([imagesArray count] * 3) - 1)) {
        if ([imagesArray count] > 1) {
            
            
            moveToPage = [imagesArray count] - 1;
            CGFloat startX = (CGFloat)moveToPage * screenwidth;
            [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
        }
        
    }
    
    if (moveToPage < [imagesArray count]) {
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    } else {
        
        moveToPage = moveToPage % [imagesArray count];
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    }
    if (([imagesArray count] > 1) && (autoSrcollEnabled)) {
        [self startTimerThread];
    }
    
    
    
    
    
    
    /////////////////////////// End Methods////////////
    
//    CGFloat width = scrollView.frame.size.width;
//    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
//    NSInteger moveToPage = page;
    if (moveToPage == 0) {
        
        moveToPage = [imagesArray count];
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
        
    } else if (moveToPage == (([imagesArray count] * 3) - 1)) {
        
        moveToPage = [imagesArray count] - 1;
        CGFloat startX = (CGFloat)moveToPage * screenwidth;
        [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
        
    }
    
    if (moveToPage < [imagesArray count]) {
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    } else {
        
        moveToPage = moveToPage % [imagesArray count];
        _pageIndicator.currentPage = moveToPage;
        _lblpagecount.text = [NSString stringWithFormat:@"%ld/%lu",moveToPage+1,(unsigned long)imagesArray.count];
    }
    
    
    
}

#pragma mark end -

- (void)slideImage {
//    1 > 2
//    NSInteger myInteger = _pageIndicator.currentPage;
//    int myInt = (int) myInteger;
//
//    if (([imagesArray count] > 1) && (myInt+1 < [imagesArray count]))
//         {
//             NSLog(@"%ld",(long)_pageIndicator.currentPage);
    CGFloat startX = 0.0f;
    CGFloat width = _sliderMainScroller.frame.size.width;
    NSInteger page = (_sliderMainScroller.contentOffset.x + (0.5f * width)) / width;
    NSInteger nextPage = page + 1;
    startX = (CGFloat)nextPage * width;
    //    [_sliderMainScroller scrollRectToVisible:CGRectMake(startX, 0, width, _sliderMainScroller.frame.size.height) animated:YES];
    [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
//         }
//    [self slidelabel:NO];
    [self withoutScrollviewchangesValues];
}
- (void)backslideImage {
//    [self slidelabel:NO];
//    NSInteger myInteger = _pageIndicator.currentPage;
//    int myInt = (int) myInteger;
//
//    if (([imagesArray count] > 1) && !(myInt <= 0))
//    {
    CGFloat startX = 0.0f;
    CGFloat width = _sliderMainScroller.frame.size.width;
    NSInteger page = (_sliderMainScroller.contentOffset.x + (0.5f * width)) / width;
    NSInteger nextPage = page - 1;
    startX = (CGFloat)nextPage * width;
    //    [_sliderMainScroller scrollRectToVisible:CGRectMake(startX, 0, width, _sliderMainScroller.frame.size.height) animated:YES];
    [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:NO];
//    }
    
    [self withoutScrollviewchangesValues];
}
- (void)autochange{
    [self slidelabel:YES];
}
- (void)slidelabel:(BOOL) animation {
    //    1 > 2
//    NSInteger myInteger = _pageIndicator.currentPage;
//    int myInt = (int) myInteger;
//
//    if (([imagesArray count] > 1) && (myInt+1 < [imagesArray count]))
//    {
//        NSLog(@"%ld",(long)_pageIndicator.currentPage);
        CGFloat startX = 0.0f;
        CGFloat width = _sliderMainScroller.frame.size.width;
        NSInteger page = (_sliderMainScroller.contentOffset.x + (0.5f * width)) / width;
        NSInteger nextPage = page + 1;
        startX = (CGFloat)nextPage * width;
        //    [_sliderMainScroller scrollRectToVisible:CGRectMake(startX, 0, width, _sliderMainScroller.frame.size.height) animated:YES];
        [_sliderMainScroller setContentOffset:CGPointMake(startX, 0) animated:animation];
//    }
}
-(void)startTimerThread
{
    if (activeTimer) {
        [activeTimer invalidate];
        activeTimer = nil;
    }
    activeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autochange) userInfo:nil repeats:YES];
}

-(void)startAutoPlay
{
    autoSrcollEnabled = YES;
    if (([imagesArray count] > 1) && (autoSrcollEnabled)) {
        [self startTimerThread];
    }
}

-(void)stopAutoPlay
{
    autoSrcollEnabled = NO;
    if (activeTimer) {
        [activeTimer invalidate];
        activeTimer = nil;
    }
}

@end
