//
//  SGSCollectionPageSegmentView.m
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGSCollectionPageSegmentView.h"
#import "SGSCollectionPageSegmentStyle.h"

static const CGFloat kTriangleWidth = 5.0;
static const CGFloat kTriangleHeight = 5.0;



@interface SGSCollectionPageSegmentView ()

@property (nonatomic, strong) UIView *cursor;              // 游标
@property (nonatomic, strong) UIScrollView *contentView;   // 内容视图
@property (nonatomic, strong) NSMutableArray *titleLabels; // 标签
@property (nonatomic, strong) NSMutableArray *titleWidths; // 标题宽度
@property (nonatomic, strong) NSMutableArray *separators;  // 分割线
@property (nonatomic, assign) NSInteger currentIndex;      // 当前标签下标
@property (nonatomic, assign) NSInteger oldIndex;          // 上一次选择的标签下标
@property (nonatomic, assign) CGFloat maskCursorMargin;    // 掩膜样式的左右延伸距离
@property (nonatomic, assign) BOOL enableScroll;           // 是否可以滑动

@property (nonatomic, strong) NSArray *normalRGBA;    // 标题默认颜色的RGBA值
@property (nonatomic, strong) NSArray *selectedRGBA;  // 标题选中颜色的RGBA值
@property (nonatomic, strong) NSArray *deltaRGBA;     // 文字颜色渐变差值

@end



@implementation SGSCollectionPageSegmentView

#pragma mark - Initializer

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    SGSCollectionPageSegmentStyle *style = [[SGSCollectionPageSegmentStyle alloc] init];
    return [self initWithFrame:frame style:style titles:@[]];
}

- (instancetype)initWithFrame:(CGRect)frame
                        style:(SGSCollectionPageSegmentStyle *)style
                       titles:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        _titles = titles;
        _titleSelectable = YES;
        
        _titleLabels = [NSMutableArray array];
        _titleWidths = [NSMutableArray array];
        _separators = [NSMutableArray array];
        
        _currentIndex = 0;
        _oldIndex = 0;
        _maskCursorMargin = 0.0;
        _enableScroll = NO;
        
        [self p_setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self p_setupTitleLabelsPosition];
    [self p_setupCursor];
}



#pragma mark - Public

// 根据标题和样式计算合适的大小
+ (CGSize)fitSizeWithTitles:(NSArray<NSString *> *)titles style:(SGSCollectionPageSegmentStyle *)style {
    
    CGFloat segmentWidth = 0.0;
    
    for (NSString *title in titles) {
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: style.titleFont}];
        segmentWidth += size.width + style.titleMargin;
    }
    
    segmentWidth += style.titleMargin;
    segmentWidth += (CGFloat)titles.count;
    
    return CGSizeMake(segmentWidth, style.segmentHeight);
}

// 根据下标选择标题
- (void)selectTitleWithIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= _titles.count) {
        return ;
    }
    
    if (_titleSelectable) {
        _currentIndex = index;
        [self p_adjustUIWithAnimated:animated];
    }
}


// 调整标题位置
- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)index animated:(BOOL)animated {
    UILabel *label = _titleLabels[index];
    
    CGFloat currentWidth = [self currentWidth];
    
    // 确保当前的标签过半的时候才可能发生位移（可让标题居中）
    CGFloat contentOffsetX = label.center.x - (currentWidth / 2);
    
    // 确保在能显示最后一个标签时不再发生位移
    CGFloat maxOffsetX = _contentView.contentSize.width - currentWidth;
    
    if (contentOffsetX < 0) {
        contentOffsetX = 0.0;
    }
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0.0;
    }
    
    if (contentOffsetX > maxOffsetX) {
        contentOffsetX = maxOffsetX;
    }
    
    // 设置位移
    [_contentView setContentOffset:CGPointMake(contentOffsetX, 0.0) animated:animated];
    
    for (UILabel *lb in _titleLabels) {
        lb.textColor = _style.normalTitleColor;
    }
    
    label.textColor = _style.selectedTitleColor;

}

// 根据进度调整UI
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex newIndex:(NSInteger)newIndex {
    
    UILabel *oldLabel     = _titleLabels[_oldIndex];
    UILabel *currentLabel = _titleLabels[newIndex];
    
    // 需要改变的距离和宽度
    CGFloat xDistance = currentLabel.frame.origin.x - oldLabel.frame.origin.x;
    CGFloat wDistance = currentLabel.frame.size.width - oldLabel.frame.size.width;
    
    CGFloat cursorX = oldLabel.frame.origin.x + xDistance * progress;
    CGFloat cursorW = oldLabel.frame.size.width + wDistance * progress;
    
    [self p_adjustCursor:cursorX width:cursorW];
    
    // 文字颜色渐变
    if (_style.colorGradient) {
        NSArray *normalRGBA = self.normalRGBA;
        NSArray *selectedRGBA = self.selectedRGBA;
        NSArray *deltaRGBA = self.deltaRGBA;
        
        oldLabel.textColor = [UIColor
                              colorWithRed:([selectedRGBA[0] floatValue] + [deltaRGBA[0] floatValue] * progress)
                              green:([selectedRGBA[1] floatValue] + [deltaRGBA[1] floatValue] * progress)
                              blue:([selectedRGBA[2] floatValue] + [deltaRGBA[2] floatValue] * progress)
                              alpha:([selectedRGBA[3] floatValue] + [deltaRGBA[3] floatValue] * progress)];
        
        currentLabel.textColor = [UIColor
                                  colorWithRed:([normalRGBA[0] floatValue] - [deltaRGBA[0] floatValue] * progress)
                                  green:([normalRGBA[1] floatValue] - [deltaRGBA[1] floatValue] * progress)
                                  blue:([normalRGBA[2] floatValue] - [deltaRGBA[2] floatValue] * progress)
                                  alpha:([normalRGBA[3] floatValue] - [deltaRGBA[3] floatValue] * progress)];
    }
    
    _oldIndex = oldIndex;
    _currentIndex = newIndex;
}

#pragma mark - Actions

- (void)p_titleLabelDidTapped:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    
    if (!_titleSelectable || view == nil) {
        return ;
    }
    
    NSInteger index = view.tag;
    
    if (index < _titles.count && index >= 0) {
        _currentIndex = index;
        [self p_adjustUIWithAnimated:YES];
    }
}

#pragma mark - Private Helper

// 设置UI
- (void)p_setupUI {
    self.backgroundColor = _style.segmentBackgroundColor;
    
    [self p_setupContentView];
    [self p_setupTitleLabels];
    [self p_setupCursor];
}

// 设置内容师徒
- (void)p_setupContentView {
    if (_contentView == nil) {
        _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.bounces = YES;
        _contentView.pagingEnabled = NO;
        [self addSubview:_contentView];
    }
}

// 设置标题标签
- (void)p_setupTitleLabels {
    if (_titles.count == 0) {
        return ;
    }
    
    if (_titleLabels == 0) {
        return ;
    }
    
    for (NSUInteger i = 0; i < _titles.count; i++) {
        NSString *title = _titles[i];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = i;
        label.text = title;
        label.textColor = _style.normalTitleColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = _style.titleFont;
        
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_titleLabelDidTapped:)]];
        
        [_titleLabels addObject:label];
        [_contentView addSubview:label];
        
        // 保存标题大小
        CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName: _style.titleFont}];
        [_titleWidths addObject:@(textSize.width)];
    }
    
    if (_style.showSeparator) {
        NSUInteger separatorCount = _titleLabels.count - 1;
        
        for (NSUInteger i = 0; i < separatorCount; i++) {
            UIView *separator = [[UIView alloc] init];
            separator.backgroundColor = _style.separatorColor;
            
            [_separators addObject:separator];
            [_contentView addSubview:separator];
        }
    }
    
    [self p_setupTitleLabelsPosition];
    
    // 设置初始标题颜色
    UILabel *firstLabel = _titleLabels.firstObject;
    firstLabel.textColor = _style.selectedTitleColor;
}

// 设置各标签的位置
- (void)p_setupTitleLabelsPosition {
    CGFloat labelX = 0.0;
    CGFloat labelY = 0.0;
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    CGFloat currentHeight = [self currentHeight];
    
    switch (_style.cursorType) {
        case SGSCollectionPageSegmentCursorLine: {
            CGFloat cursorHeight = _style.cursorHeight < currentHeight ? _style.cursorHeight : (currentHeight / 3);
            labelHeight = currentHeight - cursorHeight;
        } break;
            
        case SGSCollectionPageSegmentCursorTriangle: {
            labelHeight = currentHeight - kTriangleHeight;
        } break;
            
        default: {
            labelHeight = currentHeight;
        } break;
    }
    
    
    if (_titleWidths.count == _titleLabels.count) {
        
        CGFloat totalWidth = 0.0;
        
        for (NSNumber *width in _titleWidths) {
            totalWidth += width.floatValue + _style.titleMargin;
        }
        
        totalWidth += _style.titleMargin;
        totalWidth += _titles.count;
        
        _enableScroll = totalWidth >= [self currentWidth];
        
        if (_enableScroll || !_style.divideWhenSegmentSizeGreatTitles) {
            // 根据标题的顺序以及大小设置各个标签的位置
            
            _maskCursorMargin = _style.titleMargin / 2;
            labelX = _style.titleMargin;
            
            for (NSUInteger i = 0; i < _titleLabels.count; i++) {
                UILabel *label = _titleLabels[i];
                
                labelWidth = [_titleWidths[i] floatValue];
                label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
                
                labelX += labelWidth + (_style.titleMargin / 2);
                labelX += [self p_setupSeparatorPositionWithIndex:i x:labelX height:labelHeight];
                labelX += (_style.titleMargin / 2);
            }
            
        } else {
            // 平分宽度
            
            _maskCursorMargin = 0.0;
            labelWidth = [self currentWidth] / (CGFloat)_titles.count;
            
            for (NSUInteger i = 0; i < _titleLabels.count; i++) {
                UILabel *label = _titleLabels[i];
                label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
                
                labelX += labelWidth;
                labelX += [self p_setupSeparatorPositionWithIndex:i x:labelX height:labelHeight];
            }
            
        }
    }
    
    [self p_updateContentViewContentSize];
}

// 设置分隔线
- (CGFloat)p_setupSeparatorPositionWithIndex:(NSInteger)index x:(CGFloat)x height:(CGFloat)height {
    if (!_style.showSeparator) {
        return 0.0;
    }
    
    if (index >= _separators.count) {
        return 0.0;
    }
    
    CGFloat y = (height * 0.4) / 2;
    CGFloat sHeight = height * 0.6;
    
    UIView *separator = _separators[index];
    separator.frame = CGRectMake(x, y, 1.0, sHeight);
    
    return 1.0;
}

// 设置标记符号
- (void)p_setupCursor {
    if (_style.cursorType == SGSCollectionPageSegmentCursorNone) {
        return ;
    }
    
    if (_currentIndex >= _titleLabels.count) {
        return ;
    }
    
    if (_cursor == nil) {
        _cursor = [[UIView alloc] init];
        [_contentView addSubview:_cursor];
        [_contentView sendSubviewToBack:_cursor];
    }
    
    UILabel *label = _titleLabels[_currentIndex];
    CGFloat currentHeight = [self currentHeight];
    
    // TODO: 实现更多标记符号样式
    switch (_style.cursorType) {
        case SGSCollectionPageSegmentCursorLine: {
            CGFloat width = label.frame.size.width;
            CGFloat height = _style.cursorHeight < currentHeight ? _style.cursorHeight : (currentHeight / 3);
            CGFloat x = label.frame.origin.x;
            CGFloat y = currentHeight - height;
            
            _cursor.frame = CGRectMake(x, y, width, height);
            _cursor.backgroundColor = _style.cursorColor;
            
        } break;
            
        case SGSCollectionPageSegmentCursorBorder: {
            NSArray *value = [self p_cursorFrameAndCornerRadiusWithLabel:label];
            
            _cursor.frame = [value[0] CGRectValue];
            _cursor.backgroundColor = [UIColor clearColor];
            _cursor.layer.borderWidth = 1.0;
            _cursor.layer.borderColor = _style.cursorColor.CGColor;
            _cursor.layer.masksToBounds = YES;
            
        } break;
            
        case SGSCollectionPageSegmentCursorMask: {
            NSArray *value = [self p_cursorFrameAndCornerRadiusWithLabel:label];
            
            _cursor.frame = [value[0] CGRectValue];
            _cursor.backgroundColor = _style.cursorColor;
            _cursor.layer.cornerRadius = [value[1] floatValue];
            _cursor.layer.masksToBounds = YES;
            
        } break;
            
        default:
            break;
    }
}

// 计算游标位置和圆角
- (NSArray *)p_cursorFrameAndCornerRadiusWithLabel:(UILabel *)label {
    CGFloat width = label.frame.size.width + (2 * _maskCursorMargin);
    CGFloat height = [[_style.titleFont.fontDescriptor objectForKey:@"NSFontSizeAttribute"] floatValue];
    
    if (height < 0.000001) {
        height = 14.0;
    } else {
        height += 10.0;
    }
    
    CGFloat x = label.frame.origin.x - _maskCursorMargin;
    CGFloat y = ([self currentHeight] - height) / 2;
    
    CGFloat cornerRadius = _style.cursorCornerRadius < 0 ? (height / 2) : _style.cursorCornerRadius;
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    return @[[NSValue valueWithCGRect:rect], @(cornerRadius)];
}

// 更新内容视图大小
- (void)p_updateContentViewContentSize {
    if (_enableScroll) {
        UILabel *lastTitleLabel = _titleLabels.lastObject;
        
        if (lastTitleLabel != nil) {
            CGFloat width = CGRectGetMaxX(lastTitleLabel.frame) + _style.titleMargin;
            _contentView.contentSize = CGSizeMake(width, 0.0);
        }
        
    } else {
        _contentView.contentSize = _contentView.bounds.size;
    }
}

// 调整UI
- (void)p_adjustUIWithAnimated:(BOOL)animated {
    // 当前页是新的标签时才调整UI，否则什么都不做
    if (_currentIndex == _oldIndex) {
        return ;
    }
    
    // 确保下标合法
    if (_oldIndex >= _titleLabels.count || _currentIndex >= _titleLabels.count) {
        return ;
    }
    
    // 调整状态中禁止触发用户交互事件
    _titleSelectable = NO;
    
    // 不使用 userInteractionEnabled 是因为 self 禁止交互后
    // 交互会穿透 self ，让下一层生效
    // self.userInteractionEnabled = false 不使用该方法
    
    UILabel *oldLabel = _titleLabels[_oldIndex];
    UILabel *currentLabel = _titleLabels[_currentIndex];
    
    [self adjustTitleOffsetToCurrentIndex:_currentIndex animated:animated];
    
    NSTimeInterval animatedDuration = animated ? 0.3 : 0.0;
    
    __weak typeof(&*self) weakSelf = self;
    
    // 渐变动画
    [UIView animateWithDuration:animatedDuration animations:^{
        [weakSelf p_adjustCursor:currentLabel.frame.origin.x
                           width:currentLabel.frame.size.width];
        
    } completion:^(BOOL finished) {
        if (weakSelf == nil) return ;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;

        oldLabel.textColor = strongSelf.style.normalTitleColor;
        currentLabel.textColor = strongSelf.style.selectedTitleColor;
        
        // 恢复触发用户交互事件
        strongSelf.titleSelectable = YES;
        strongSelf.oldIndex = strongSelf.currentIndex;
        
        // 触发代理方法
        if ((strongSelf.delegate != nil) && [strongSelf.delegate respondsToSelector:@selector(collectionPageSegmentView:didSelectedTitle:index:)]) {
            [strongSelf.delegate collectionPageSegmentView:strongSelf
                                          didSelectedTitle:currentLabel
                                                     index:strongSelf.currentIndex];
        }
    }];
}

// 调整游标
- (void)p_adjustCursor:(CGFloat)x width:(CGFloat)width {
    if (_cursor == nil) {
        return;
    }
    
    switch (_style.cursorType) {
        case SGSCollectionPageSegmentCursorNone:
        case SGSCollectionPageSegmentCursorTriangle:
            break;
            
        case SGSCollectionPageSegmentCursorLine: {
            _cursor.frame = CGRectMake(x,
                                       _cursor.frame.origin.y,
                                       width,
                                       _cursor.frame.size.height);
        } break;
            
        case SGSCollectionPageSegmentCursorBorder:
        case SGSCollectionPageSegmentCursorMask: {
            _cursor.frame = CGRectMake(x - _maskCursorMargin,
                                       _cursor.frame.origin.y,
                                       width + (2 * _maskCursorMargin),
                                       _cursor.frame.size.height);
        } break;
            
        default:
            break;
    }
}

// 获取颜色的RGBA值
- (NSArray *)p_getColorRGBA:(UIColor *)color {
    
    CGColorRef cgColor = color.CGColor;
    size_t count = CGColorGetNumberOfComponents(cgColor);
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    if (count == 2) {
        CGFloat white = components[0];
        CGFloat alpha = components[1];
        
        return @[@(white), @(white), @(white), @(alpha)];
        
    } else if (count == 4) {
        CGFloat red   = components[0];
        CGFloat green = components[1];
        CGFloat blue  = components[2];
        CGFloat alpha = components[3];
        
        return @[@(red), @(green), @(blue), @(alpha)];
    }
    
    return @[@(0.0), @(0.0), @(0.0), @(1.0)];
}


#pragma mark - getter & setter

// 设置背景图片
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.layer.contents = (__bridge id _Nullable)(_backgroundImage.CGImage);
}

// 设置标题数组
- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    
    // 清空之前的状态
    for (UIView *view in _contentView.subviews) {
        [view removeFromSuperview];
    }
    _cursor = nil;
    [_titleLabels removeAllObjects];
    [_titleWidths removeAllObjects];
    [_separators removeAllObjects];
    
    // 重置状态
    _currentIndex = 0;
    _oldIndex = 0;
    [self p_setupUI];
    [self p_adjustUIWithAnimated:YES];
    _titleSelectable = YES;
    
}

// 当前视图宽度
- (CGFloat)currentWidth {
    return self.bounds.size.width;
}

// 当前视图高度
- (CGFloat)currentHeight {
    return self.bounds.size.height;
}

// 标题普通状态下的颜色
- (NSArray *)normalRGBA {
    if (_normalRGBA == nil) {
        _normalRGBA = [self p_getColorRGBA:self.style.normalTitleColor];
    }
    return _normalRGBA;
}

// 选择状态下标题的颜色
- (NSArray *)selectedRGBA {
    if (_selectedRGBA == nil) {
        _selectedRGBA = [self p_getColorRGBA:self.style.selectedTitleColor];
    }
    return _selectedRGBA;
}

// 标题颜色差值
- (NSArray *)deltaRGBA {
    if (_deltaRGBA == nil) {
        NSArray *normal = self.normalRGBA;
        NSArray *selected = self.selectedRGBA;
        if (normal != nil && selected != nil) {
            CGFloat deltaR = [normal[0] floatValue] - [selected[0] floatValue];
            CGFloat deltaG = [normal[1] floatValue] - [selected[1] floatValue];
            CGFloat deltaB = [normal[2] floatValue] - [selected[2] floatValue];
            CGFloat deltaA = [normal[3] floatValue] - [selected[3] floatValue];
            _deltaRGBA = @[@(deltaR), @(deltaG), @(deltaB), @(deltaA)];
        }
    }
    return _deltaRGBA;
    
}

@end
