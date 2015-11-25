#import "HorizontalScroller.h"

#define VIEW_PADDING    10
#define VIEW_DIMENSIONS 100
#define VIEWS_OFFSET    100

@interface HorizontalScroller () <UIScrollViewDelegate>
@end


@implementation HorizontalScroller
{
    UIScrollView *scroller;
}

#pragma mark - LifeCycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        
        [self addSubview:scroller];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        
        [scroller addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    [self reload];
}

#pragma mark - Method
- (void)reload
{
    if (self.dddelegate == nil)
        return;
    
    // 2 - remove all subviews
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // 3 - xValue is the starting point of the views inside the scroller
    CGFloat xValue = VIEWS_OFFSET;
    for (int i=0; i<[self.dddelegate numberOfViewsForHorizontalScroller:self]; i++){
        
        // 4 - add a view at the right position
        xValue += VIEW_PADDING;
        
        UIView *view = [self.dddelegate horizontalScroller:self viewAtIndex:i];
        view.frame   = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        
        [scroller addSubview:view];
        
        xValue += VIEW_DIMENSIONS+VIEW_PADDING;
    }
    
    // 5
    [scroller setContentSize:CGSizeMake(xValue+VIEWS_OFFSET, self.frame.size.height)];
    
    // 6 - if an initial view is defined, center the scroller on it
    if ([self.dddelegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)]){
        
        NSInteger initialView = [self.dddelegate initialViewIndexForHorizontalScroller:self];
        
        [scroller setContentOffset:CGPointMake(initialView*(VIEW_DIMENSIONS+(2*VIEW_PADDING)), 0) animated:YES];
    }
}

- (void)centerCurrentView
{
    int xFinal    = scroller.contentOffset.x + (VIEWS_OFFSET/2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    
    xFinal = viewIndex * (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    
    [scroller setContentOffset:CGPointMake(xFinal,0) animated:YES];
    [self.dddelegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

#pragma mark - Touch
- (void)scrollerTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];

    for (int index=0; index<[self.dddelegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.dddelegate horizontalScroller:self clickedViewAtIndex:index];
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate){
        
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

@end
