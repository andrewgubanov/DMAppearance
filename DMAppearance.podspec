Pod::Spec.new do |s|
  s.name = "DMAppearance"
  s.version = "0.1.1"
  s.summary = "Partial functionality from UIAppearance proxy for custom objects"
  s.description = <<-DESC
                   * Partial functionality from UIAppearance proxy for custom objects apart from UIKit ones
                   DESC
  s.homepage = "https://github.com/andrewgubanov/DMAppearance"
  s.license = {
    :type => 'MIT',
    :file => 'LICENSE.md'
  }
  s.author = { "AG" => "andrew.gubanov@icloud.com" }
  s.platform = :ios, '7.0'
  s.source = {
    :git => 'https://github.com/andrewgubanov/DMAppearance.git',
    :tag => s.version.to_s
  }
  s.source_files = 'DMAppearance/*.{h,m}'
  s.frameworks = 'Foundation', 'CoreGraphics'
  s.requires_arc = true
end
