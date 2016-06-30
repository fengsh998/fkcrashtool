//
//  FKRadioGroup.m
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/16.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "FKRadioGroup.h"

@implementation FKRadioGroup

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
//        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
//
//        [self updateTrackingAreas];
    }
    
    return self;
}


//此方法需要在改变的时候手动调用一次(父类的方法)
- (void)updateTrackingAreas
{
    NSArray *trackings = [self trackingAreas];
    for (NSTrackingArea *tracking in trackings)
    {
        [self removeTrackingArea:tracking];
    }
    
    //添加NSTrackingActiveAlways掩码可以使视图未处于激活或第一响应者时也能响应相应的方法
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)awakeFromNib
{
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
}

//奇怪，真奇怪，所有窗口事件都会触发这个
- (nullable NSView *)hitTest:(NSPoint)aPoint
{
    NSPoint location = [self convertPoint:aPoint fromView:self.superview];
    BOOL inrect = NSPointInRect(location, self.bounds);
    
    if (inrect) {
        return self;
    }
    
    return [super hitTest:aPoint];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
    //判断点击位置是否在本view中
    BOOL inrect = NSPointInRect(location, self.bounds);

    if (inrect) {
        //转换到当前view的点击坐标
        CGPoint pt = [self convertPoint:location toView:self.superview];

        NSView *v = [super hitTest:pt];
        //不是当前view
        if (v != self) {
            //说明点击到某一控件上了
            if (v && [v isKindOfClass:[NSButton class]]) {
                for (NSView *item in self.subviews) {
                    if ([item isKindOfClass:[NSButton class]])
                    {
                        NSButton *btn = (NSButton*)item;
                        [btn setState:NSOffState];
                    }
                }
                
                [((NSButton *)v) setState:NSOnState];
                [((NSButton *)v) mouseDown:theEvent];
            }
            else
            {   //交由其它可点击的控件处理
                if ([v respondsToSelector:@selector(mouseDown:)])
                {
                    [v mouseDown:theEvent];
                }
            }
        }
    }
}

@end
