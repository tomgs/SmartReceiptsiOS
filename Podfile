platform :ios, '10.0'

inhibit_all_warnings!
use_frameworks!

project 'SmartReceipts.xcodeproj'

def pods
    #AWS
    pod 'AWSCognito'
    pod 'AWSS3'
    
    # File storage
    pod 'FMDB'
    pod 'Zip'
    
    # UI
    pod 'MRProgress', git: 'https://github.com/EvsenevDev/MRProgress', branch: 'disabled-motions'
    pod 'Eureka'
    pod 'XLPagerTabStrip', git: 'https://github.com/alexanderkhitev/XLPagerTabStrip.git'
    pod 'Floaty', git: 'https://github.com/QuestofIranon/Floaty.git'
    pod 'Toaster', git: 'https://github.com/devxoul/Toaster.git'
    
    # Rx
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'Moya/RxSwift'
    
    # Utilites
    pod 'CocoaLumberjack/Swift'
    pod 'Alamofire'
    pod 'Moya'
    
    # Firebase
    pod 'Firebase/Core'
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/AdMob'
    
    # Google
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'GTMAppAuth'
    pod 'GoogleAPIClientForREST/Drive'
    pod 'GoogleSignIn'
    
    # Purchases
    pod 'SwiftyStoreKit'
    
    # Architecture
    pod 'Viperit'
    
end

target 'SmartReceipts' do
    pods
end

target 'SmartReceiptsTests' do
    pods
    pod 'RxBlocking'
    pod 'RxTest'
    pod 'Cuckoo'

end
