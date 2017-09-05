//
//  SGSCollectionPageSegmentStyle.h
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  标签的游标样式
 */
typedef NS_ENUM(NSInteger, SGSCollectionPageSegmentCursor) {
    SGSCollectionPageSegmentCursorNone     = 0,  // 不使用游标
    SGSCollectionPageSegmentCursorLine     = 1,  // 滚动条样式
    SGSCollectionPageSegmentCursorTriangle = 2,  // 三角标样式（暂不支持）
    SGSCollectionPageSegmentCursorBorder   = 3,  // 外边框样式
    SGSCollectionPageSegmentCursorMask     = 4,  // 掩膜样式
};


/**
 *  集合页面视图标签栏样式
 */
@interface SGSCollectionPageSegmentStyle : NSObject

/// 标签栏默认高度（默认44.0）
@property (nonatomic, assign) CGFloat segmentHeight;


/// 标签栏默认背景颜色（默认为白色）
@property (nonatomic, strong) UIColor *segmentBackgroundColor;


/// 是否让标题颜色渐变（默认为YES）
@property (nonatomic, assign) BOOL colorGradient;


/// 默认标题颜色（默认为灰色）
@property (nonatomic, strong) UIColor *normalTitleColor;


/// 选中时的标题颜色（默认为红色）
@property (nonatomic, strong) UIColor *selectedTitleColor;


/// 标题字体（默认为17磅的系统样式）
@property (nonatomic, strong) UIFont *titleFont;


/// 标签间距（默认为10.0）
@property (nonatomic, assign) CGFloat titleMargin;


/// 是否显示分割线（默认为NO）
@property (nonatomic, assign) BOOL showSeparator;


/// 分割线颜色（默认为亮灰色）
@property (nonatomic, strong) UIColor *separatorColor;


/// 当标签栏的宽度大于所有标题宽度之和时，平分各标签的宽度，标题宽度将根据标题字体以和字符串计算（默认为YES）
@property (nonatomic, assign) BOOL divideWhenSegmentSizeGreatTitles;


/// 标签的游标样式（默认为滚动条）
@property (nonatomic, assign) SGSCollectionPageSegmentCursor cursorType;


/// 游标高度，只对滚动条样式有效（默认为2.0）
@property (nonatomic, assign) CGFloat cursorHeight;


/// 游标圆角，只对外边框和掩膜样式有效，负数时表示自适应（默认为-1.0)
@property (nonatomic, assign) CGFloat cursorCornerRadius;


/// 游标颜色（默认为红色）
@property (nonatomic, strong) UIColor *cursorColor;


@end

NS_ASSUME_NONNULL_END