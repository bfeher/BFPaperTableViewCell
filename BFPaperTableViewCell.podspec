
Pod::Spec.new do |s|
  s.name         = "BFPaperTableViewCell"
  s.version      = "1.0"
  s.summary      = "A flat button inspired by Google Material Design's Paper theme."
  s.homepage     = "https://github.com/bfeher/BFPaperTableViewCell"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Bence Feher" => "ben.feher@gmail.com" }
  s.source       = { :git => "https://github.com/bfeher/BFPaperTableViewCell.git", :tag => "1.0" }
  s.platform     = :ios, '7.0'
  s.dependency   'UIColor+BFPaperColors'
 
  
  s.source_files = 'BFPaperTableViewCell', 'BFPaperTableViewCell/**/*.{h,m}'
  s.public_header_files = 'BFPaperTableViewCell/**/*.h'
  s.requires_arc = true

end
