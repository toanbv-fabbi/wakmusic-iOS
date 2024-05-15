//
//  Utils.swift
//  Utility
//
//  Created by KTH on 2023/01/01.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import UIKit

public func APP_WIDTH() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

public func APP_HEIGHT() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

public func PLAYER_HEIGHT() -> CGFloat {
    return 56.0
}

public func STATUS_BAR_HEGHIT() -> CGFloat {
    return max(20, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
}

public func SAFEAREA_BOTTOM_HEIGHT() -> CGFloat {
    return if #available(iOS 15.0, *) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .keyWindow?
            .safeAreaInsets
            .bottom ?? 0
    } else {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .windows
            .first(where: \.isKeyWindow)?
            .safeAreaInsets
            .bottom ?? 0
    }
}

public func APP_VERSION() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}

public func APP_NAME() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
}

public func OS_VERSION() -> String {
    return UIDevice.current.systemVersion
}

public func OS_NAME() -> String {
    let osName: String = {
        #if os(iOS)
            #if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
            #else
                return "iOS"
            #endif
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(macOS)
            return "macOS"
        #elseif os(Linux)
            return "Linux"
        #elseif os(Windows)
            return "Windows"
        #else
            return "Unknown"
        #endif
    }()
    return osName
}

// use: colorFromRGB(0xffffff)
public func colorFromRGB(_ rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0xFF) / 255.0,
        alpha: alpha
    )
}

// use: colorFromRGB("ffffff")
public func colorFromRGB(_ hexString: String, alpha: CGFloat = 1.0) -> UIColor {
    let hexToInt = UInt32(Float64("0x" + hexString) ?? 0)
    return UIColor(
        red: CGFloat((hexToInt & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hexToInt & 0xFF00) >> 8) / 255.0,
        blue: CGFloat(hexToInt & 0xFF) / 255.0,
        alpha: alpha
    )
}

public func DEBUG_LOG(_ msg: Any, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        let fileName = file.split(separator: "/").last ?? ""
        let funcName = function.split(separator: "(").first ?? ""
        print("[\(fileName)] \(funcName)(\(line)): \(msg)")
    #endif
}
