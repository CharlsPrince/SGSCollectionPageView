Pod::Spec.new do |s|

  s.name         = 'SGSCollectionPageView'
  s.version      = '0.1.2'
  s.summary      = '集合页面视图'

  s.homepage     = 'https://github.com/CharlsPrince/SGSCollectionPageView'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'CharlsPrince' => '961629701@qq.com' }

  s.platform     = :ios, '8.0'
  s.source       = { :git => 'https://github.com/CharlsPrince/SGSCollectionPageView.git', :tag => s.version.to_s }


  s.source_files  = 'SGSCollectionPageView/*.{h,m}'
  s.public_header_files = 'SGSCollectionPageView/*.{h}'

  s.framework     = 'UIKit'
  s.requires_arc  = true


end
