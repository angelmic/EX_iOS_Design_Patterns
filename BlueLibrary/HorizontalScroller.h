#import <UIKit/UIKit.h>

@protocol HorizontalScrollerDelegate;

@interface HorizontalScroller : UIView
{
    
}
@property (weak) id<HorizontalScrollerDelegate>dddelegate;

-(void)reload;
@end

#pragma mark - HorizontalScrollerDelegate
@protocol HorizontalScrollerDelegate <NSObject>

@required
-(NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller;
-(UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index;
-(void)horizontalScroller:(HorizontalScroller*)scroller clickedViewAtIndex:(int)index;

@optional
-(NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller*)scroller;

@end

