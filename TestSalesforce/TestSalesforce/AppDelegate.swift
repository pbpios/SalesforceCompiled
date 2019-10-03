//
//  AppDelegate.swift
//  TestSalesforce
//
//  Created by Prashant on 9/27/19.
//  Copyright © 2019 Prashant. All rights reserved.
//

import UIKit
import SalesforceSDKCore

import MobileCoreServices

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    override init() {
        
        super.init()
        
        SalesforceManager.initializeSDK()
        SalesforceManager.shared.appDisplayName = "Rest API Explorer"
        
        //Uncomment following block to enable IDP Login flow.
        //SalesforceManager.shared.identityProviderURLScheme = "sampleidpapp"
        AuthHelper.registerBlock(forCurrentUserChangeNotifications: {
            self.resetViewState {
                self.initializeAppViewState()
                self.setupRootViewController()
            }
        })
    }
    
    // MARK: - App delegate lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState()
        
        // If you wish to register for push notifications, uncomment the line below.  Note that,
        // if you want to receive push notifications from Salesforce, you will also need to
        // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
        //
        // SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()
        
        //Uncomment the code below to see how you can customize the color, textcolor,
        //font and fontsize of the navigation bar
        //let loginViewConfig = SalesforceLoginViewControllerConfig()
        
        //Set showSettingsIcon to false if you want to hide the settings
        //icon on the nav bar
        //loginViewConfig.showsSettingsIcon = false
        
        //Set showNavBar to false if you want to hide the top bar
        //loginViewConfig.showsNavigationBar = false
        //loginViewConfig.navigationBarColor = UIColor(red: 0.051, green: 0.765, blue: 0.733, alpha: 1.0)
        //loginViewConfig.navigationBarTextColor = UIColor.white
        //loginViewConfig.navigationBarFont = UIFont(name: "Helvetica", size: 16.0)
        //UserAccountManager.shared.loginViewControllerConfig = loginViewConfig
        
        // Uncomment the code below to customize the color, textcolor and font of the Passcode,
        // Touch Id and Face Id lock screens.  To use this feature please enable inactivity timeout
        // in your connected app.
        //
        //let passcodeViewConfig = AppLockViewControllerConfig()
        //passcodeViewConfig.backgroundColor = UIColor.black
        //passcodeViewConfig.primaryColor = UIColor.orange
        //passcodeViewConfig.secondaryColor = UIColor.gray
        //passcodeViewConfig.titleTextColor = UIColor.white
        //passcodeViewConfig.instructionTextColor = UIColor.white
        //passcodeViewConfig.borderColor = UIColor.yellow
        //passcodeViewConfig.maxNumberOfAttempts = 3
        //passcodeViewConfig.forcePasscodeLength = true
        //UserAccountManager.shared.appLockViewControllerConfig = passcodeViewConfig
        
        AuthHelper.loginIfRequired {
            self.setupRootViewController()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //
        // Uncomment the code below to register your device token with the push notification manager
        //
        //
        // SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        // if let _ = UserAccountManager.shared.currentUserAccount?.credentials.accessToken {
        //     SFPushNotificationManager.sharedInstance().registerSalesforceNotifications(completionBlock: {
        //         SalesforceLogger.e(AppDelegate.self, message: "Registration for Salesforce notifications succeeded")
        //     }, fail: {
        //         SalesforceLogger.e(AppDelegate.self, message: "Registration for Salesforce notifications failed")
        //     })
        // }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        // Respond to any push notification registration errors here.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // Uncomment following block to enable IDP Login flow
        // return  UserAccountManager.shared.handleIdentityProviderResponse(from: url, with: options)
        return false;
    }
    
    // MARK: - Private methods
    func initializeAppViewState() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.initializeAppViewState()
            }
            return
        }
        
        self.window!.rootViewController = InitialViewController(nibName: nil, bundle: nil)
        self.window!.makeKeyAndVisible()
    }
    
    func setupRootViewController() {
        let rootVC = RootViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: rootVC)
        self.window!.rootViewController = navVC
    }
    
    func resetViewState(_ postResetBlock: @escaping () -> Void ) {
        if let rootViewController = self.window!.rootViewController {
            if let _ = rootViewController.presentedViewController {
                rootViewController.dismiss(animated: false, completion: postResetBlock)
                return
            }
        }
        postResetBlock()
    }
    
    func exportTestingCredentials() {
        guard let creds = UserAccountManager.shared.currentUserAccount?.credentials,
            let instance = creds.instanceUrl,
            let identity = creds.identityUrl
            else {
                return
        }
        
        var config = ["test_client_id": SalesforceManager.shared.bootConfig?.remoteAccessConsumerKey,
                      "test_login_domain": UserAccountManager.shared.loginHost,
                      "test_redirect_uri": SalesforceManager.shared.bootConfig?.oauthRedirectURI,
                      "refresh_token": creds.refreshToken,
                      "instance_url": instance.absoluteString,
                      "identity_url": identity.absoluteString,
                      "access_token": "__NOT_REQUIRED__"]
        if let community = creds.communityUrl {
            config["community_url"] = community.absoluteString
        }
        
        let configJSON = SFJsonUtils.jsonRepresentation(config)
        let board = UIPasteboard.general
        board.setValue(configJSON, forPasteboardType: kUTTypeUTF8PlainText as String)
    }
}
