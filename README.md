Southgis iOS(OC) 移动支撑平台组件 - 集合页面视图
CI Status Version License Platform

SGSCollectionPageView（OC版本）是移动支撑平台 iOS Objective-C 组件之一，使用该组件可以方便将多个视图控制器集合在一起，并以滚动翻页的形式加载各控制器的视图

安装
SGSCollectionPageView 可以通过 Cocoapods 进行安装，可以复制下面的文字到 Podfile 中：

target "项目名称" do
pod "SGSCollectionPageView"
end
原理
集合视图（ SGSCollectionPageView ）分为上下两个部分：分段标题视图（ SGSCollectionPageSegmentView ）和内容视图（ SGSCollectionPageContentView ）

分段标题视图以 UIScrollView 为底图，各标题以 UILabel 展示，通过 SGSCollectionPageSegmentStyle 来控制展示样式

内容视图以 UICollectionView 为底图，各子控制器的视图以铺满的 UICollectionViewCell 形式展示在 UICollectionView 上通过切换 cell 来实现切换控制器视图的效果

效果图
无游标样式

滚动条样式

外边框样式

掩膜样式

带有分隔线的样式

平均宽度

使用说明
SGSCollectionPageView 提供了根据标题和子视图控制器初始化方法，并且必须保证标题的数量与子视图控制器的数量一致，标题的显示样式根据 SGSCollectionPageSegmentStyle 来控制

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;

    // 标题与视图控制器
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    UIViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"Live"];
    UIViewController *vc2 = [sb instantiateViewControllerWithIdentifier:@"Fans"];
    UIViewController *vc3 = [sb instantiateViewControllerWithIdentifier:@"Records"];

    NSArray *subVCs = @[vc1, vc2, vc3];
    NSArray *subTitles = @[@"Live", @"我的关注", @"足迹"];

    // 创建标题分段样式
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];

    // 集合视图
    SGSCollectionPageView *pageView = [SGSCollectionPageView pageViewWithFrame:self.view.bounds style:style titles:subTitles childViewControllers:subVCs parentViewController:self];

    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:pageView];
}
SGSCollectionPageSegmentStyle
标签分段样式

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
未来
目前暂不支持三角形游标样式，考虑以后添加

结尾
移动支撑平台 是研发中心移动团队打造的一套移动端开发便捷技术框架。这套框架立旨于满足公司各部门不同的移动业务研发需求，实现App快速定制的研发目标，降低研发成本，缩短开发周期，达到代码的易扩展、易维护、可复用的目的，从而让开发人员更专注于产品或项目的优化与功能扩展

整体框架采用组件化方式封装，以面向服务的架构形式供开发人员使用。同时兼容 Android 和 iOS 两大移动平台，涵盖 网络通信, 数据持久化存储, 数据安全, 移动ArcGIS 等功能模块（近期推出混合开发组件，只需采用前端的开发模式即可同时在 Android 和 iOS 两个平台运行），各模块间相互独立，开发人员可根据项目需求使用相应的组件模块

更多组件请参考：

HTTP 请求模块组件
数据安全组件
数据持久化存储组件
ArcGIS绘图组件
常用类别组件
常用工具组件
二维码扫描与生成
如果您对移动支撑平台有更多的意见和建议，欢迎联系我们！

研发中心移动团队

2016 年 08月 31日

Author
Lee, kun.li@southgis.com

License
SGSDatabase is available under the MIT license. See the LICENSE file for more info.
