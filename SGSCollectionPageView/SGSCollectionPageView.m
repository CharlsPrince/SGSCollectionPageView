//
//  SGSCollectionPageView.m
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGSCollectionPageView.h"
#import "SGSCollectionPageSegmentView.h"
#import "SGSCollectionPageContentView.h"

@interface SGSCollectionPageView () <SGSCollectionPageSegmentViewDelegate, SGSCollectionPageContentViewDelegate>

@property (nonatomic, strong, readwrite) SGSCollectionPageSegmentView *segment;
@property (nonatomic, strong, readwrite) SGSCollectionPageContentView *contentView;

@property (nonatomic, assign) CGFloat segmentHeight;
@property (nonatomic, strong) NSLayoutConstraint *segmentTopConstraint;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation SGSCollectionPageView

+ (instancetype)pageViewWithFrame:(CGRect)frame
                            style:(SGSCollectionPageSegmentStyle *)style
                           titles:(NSArray<NSString *> *)titles
             childViewControllers:(NSArray<UIViewController *> *)childVCs
             parentViewController:(UIViewController *)parentVC
{
    return [[SGSCollectionPageView alloc] initWithFrame:frame style:style titles:titles childViewControllers:childVCs parentViewController:parentVC];
}

- (instancetype)initWithFrame:(CGRect)frame
                        style:(SGSCollectionPageSegmentStyle *)style
                       titles:(NSArray<NSString *> *)titles
         childViewControllers:(NSArray<UIViewController *> *)childVCs
         parentViewController:(UIViewController *)parentVC
{
    if (titles.count != childVCs.count) return nil;
    
    self = [super initWithFrame:frame];
    if (self) {
        _scrollEnabled = YES;
        _hideSegment = NO;
        _currentIndex = 0;
        
        _segmentHeight = style.segmentHeight;
        
        CGRect contentViewFrame = CGRectMake(0, _segmentHeight, frame.size.width, frame.size.height - _segmentHeight);
        
        _contentView = [[SGSCollectionPageContentView alloc]
                        initWithFrame:contentViewFrame
                        childViewControllers:childVCs
                        parentViewController:parentVC];
        
        _contentView.scrollEnabled = _scrollEnabled;
        
        CGRect segmentFrame = CGRectMake(0, 0, frame.size.width, _segmentHeight);
        
        _segment = [[SGSCollectionPageSegmentView alloc]
                    initWithFrame:segmentFrame
                    style:style
                    titles:titles];

        [self p_setupUI];
    }
    return self;
}

#pragma mark - Public Methods

// 滚动到指定页面
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated {
    [_segment selectTitleWithIndex:index animated:animated];
    [_contentView scrollPageToIndex:index animated:animated];
}

// 重新设置内容
- (void)resetWithTitles:(NSArray<NSString *> *)titles
   childViewControllers:(NSArray<UIViewController *> *)childVCs
   parentViewController:(UIViewController *)parentVC
{
    _segment.titles = titles;
    [_contentView resetChildViewControllers:childVCs parentViewController:parentVC];
}


#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 调整位置
    [_segment adjustUIWithProgress:1.0 oldIndex:_currentIndex newIndex:_currentIndex];
    [_segment adjustTitleOffsetToCurrentIndex:_currentIndex animated:YES];
    
    [_contentView scrollPageToIndex:_currentIndex animated:YES];
}



#pragma mark - Private Helper

// 设置UI
- (void)p_setupUI {
    self.backgroundColor = [UIColor whiteColor];
    
    _contentView.delegate = self;
    _segment.delegate = self;
    
    [self addSubview:_contentView];
    [self addSubview:_segment];

    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _segment.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSNumber *segmentHeight = @(_segmentHeight);
    
    NSDictionary *bindingViews = NSDictionaryOfVariableBindings(_segment, _contentView);
    NSDictionary *metrics      = NSDictionaryOfVariableBindings(segmentHeight);
    
    NSArray *segmentConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_segment]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:bindingViews];
    [self addConstraints:segmentConstraintH];
    
    NSArray *contentViewConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:bindingViews];
    [self addConstraints:contentViewConstraintH];
    
    NSArray *constraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_segment(==segmentHeight)]-0-[_contentView]-0-|" options:kNilOptions metrics:metrics views:bindingViews];
    [self addConstraints:constraintV];
    
    _segmentTopConstraint = [NSLayoutConstraint constraintWithItem:_segment
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0.0];
    
    [self addConstraint:_segmentTopConstraint];
    
    [self layoutIfNeeded];
}


#pragma mark - SGSCollectionPageSegmentViewDelegate

- (void)collectionPageSegmentView:(SGSCollectionPageSegmentView *)view
                 didSelectedTitle:(UILabel *)titleLabel
                            index:(NSInteger)index
{
    [_contentView scrollPageToIndex:index animated:NO];
}



#pragma mark - SGSCollectionPageContentViewDelegate

- (void)collectionPageContentView:(SGSCollectionPageContentView *)view
                  didScrollToPage:(NSInteger)pageIndex
{
    _currentIndex = pageIndex;
    
    // 恢复标题可选
    _segment.titleSelectable = YES;
    
    // 调整标题位置
    [_segment adjustUIWithProgress:1.0 oldIndex:pageIndex newIndex:pageIndex];
    [_segment adjustTitleOffsetToCurrentIndex:pageIndex animated:YES];
    
    // 触发代理方法
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(collectionPageView:didScrollToPage:)]) {
        [self.delegate collectionPageView:self didScrollToPage:pageIndex];
    }
}



- (void)collectionPageContentView:(SGSCollectionPageContentView *)view
                       scrollFrom:(NSInteger)oldIndex
                               to:(NSInteger)newIndex
                         progress:(CGFloat)progress
{
    [_segment adjustUIWithProgress:progress oldIndex:oldIndex newIndex:newIndex];
}


- (void)collectionPageContentViewWillBeginDragging:(SGSCollectionPageContentView *)view {
    // 开始滑动的时候不能选择，直至滑动完毕为止
    _segment.titleSelectable = NO;
}



#pragma mark - gettser & setter 

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.contentView.scrollEnabled = scrollEnabled;
}

- (void)setHideSegment:(BOOL)hideSegment {
    _hideSegment = hideSegment;
    
    if (_hideSegment) {
        _segmentTopConstraint.constant = -_segmentHeight;
    } else {
        _segmentTopConstraint.constant = 0;
    }
}

@end
