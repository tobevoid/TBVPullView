Pod::Spec.new do |s|
    s.name         = 'TBVPullView'
    s.version      = '1.0.0'
    s.summary      = 'Add pull to refresh to any scrollView'
    s.homepage     = 'https://github.com/tobevoid/TBVPullView'
    s.license      = 'MIT'
    s.authors      = {'tripleCC' => 'triplec.linux@gmail.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/tobevoid/TBVPullView.git', :tag => s.version}
    s.source_files = ["TBVPullView/TBVPullView/Classes/TVBPullView.swift"]
    s.requires_arc = true
end
