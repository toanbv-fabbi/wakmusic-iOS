import UIKit
import RootFeature
import NaverThirdPartyLogin
import AVKit
import Utility
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        // configure NaverThirdPartyLoginConnection
        let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        naverInstance?.isNaverAppOauthEnable = true //네이버앱 로그인 설정
        naverInstance?.isInAppOauthEnable = true //사파리 로그인 설정
        naverInstance?.setOnlyPortraitSupportInIphone(true)
        
        DEBUG_LOG("NAVER_URL_SCHEME: \(NAVER_URL_SCHEME())")
        naverInstance?.serviceUrlScheme = NAVER_URL_SCHEME() //URL Scheme
        naverInstance?.consumerKey = NAVER_CONSUMER_KEY() //클라이언트 아이디
        naverInstance?.consumerSecret = NAVER_CONSUMER_SECRET() //시크릿 아이디
        naverInstance?.appName = NAVER_APP_NAME() //앱이름

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
        } catch let error {
            DEBUG_LOG(error.localizedDescription)
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {

    }
}
