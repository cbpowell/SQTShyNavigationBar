Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.name         = "SQTShyNavigationBar"
  s.version      = "1.0"
  s.summary      = "A shrinking (shy) navigation bar that automatically adjusts as a user scrolls, with customizable full and shy heights."

  s.description  = <<-DESC
                    A shrinking (shy) navigation bar that automatically adjusts as a user scrolls, with customizable full and shy heights.

                    The goal of SQTShyNavigationBar is to be as __robust__ as possible, smoothly handling the trickier edge cases - even if that means a little more integration work for you, the developer.
                   DESC

  s.homepage     = "http://github.com/cbpowell/SQTShyNavigationBar"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.author             = { "Charles Powell" => "cbpowell@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios, "7.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.source       = { :git => "https://github.com/cbpowell/SQTShyNavigationBar.git", :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "Classes", "Pod/SQTShyNavigationBar.{h,m}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

end
