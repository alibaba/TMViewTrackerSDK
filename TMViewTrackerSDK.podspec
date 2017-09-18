Pod::Spec.new do |s|

  s.name         = "TMViewTrackerSDK"
  s.version  = "1.0.3.8"
  s.summary      = "A short description of TMDataCollectionSDK."

  s.description  = <<-DESC
                   A longer description of TMClientCategory in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://www.tmall.com/TMClientCategory"

  s.license      = {
        :type => 'Copyright',
        :text => <<-LICENSE
            Alibaba-INC copyright
LICENSE
    }

  s.license      = "MIT (example)"
  s.author             = { }

  s.platform     = :ios, "6.0"


  s.source       = { }


  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/UserTrack'}
  s.source_files  = "TMViewTrackerSDK", "TMViewTrackerSDK/**/*.{h,c,m}"
end
