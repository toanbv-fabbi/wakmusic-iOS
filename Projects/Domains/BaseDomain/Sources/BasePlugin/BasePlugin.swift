import Foundation
import KeychainModule
import Moya
import UIKit

public struct BasePlugin: PluginType {
    private let keychain: any Keychain

    public init(keychain: any Keychain) {
        self.keychain = keychain
    }

    public func prepare(
        _ request: URLRequest,
        target: TargetType
    ) -> URLRequest {
        guard let deviceInfoTypes = (target as? DeviceInfoSendable)?.deviceInfoTypes,
              deviceInfoTypes.isEmpty == false else {
            return request
        }
        var newRequest = request

        if request.httpMethod == "GET" {
            guard let url = request.url,
                  var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return request
            }

            var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

            for type in deviceInfoTypes {
                let queryItem = URLQueryItem(name: type.apiKey, value: typeToValue(with: type))
                queryItems.append(queryItem)
            }

            urlComponents.queryItems = queryItems
            newRequest.url = urlComponents.url

        } else {
            guard let bodyData = request.httpBody,
                  var json = try? JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] else {
                return request
            }

            for type in deviceInfoTypes {
                json[type.apiKey] = typeToValue(with: type)
            }

            guard let newBodyData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                return request
            }
            newRequest.httpBody = newBodyData
        }

        return newRequest
    }
}

private extension BasePlugin {
    func typeToValue(with type: DeviceInfoType) -> String {
        switch type {
        case .os:
            return "ios"
        case .version:
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        case .deviceID:
            return fetchDeviceID()
        case .pushToken:
            return fetchPushToken()
        }
    }

    func fetchDeviceID() -> String {
        if keychain.load(type: .deviceID).isEmpty {
            let uuidString: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
            keychain.save(type: .deviceID, value: uuidString)
            return uuidString

        } else {
            return keychain.load(type: .deviceID)
        }
    }

    #warning("FCM SDK 셋업 이후 작업")
    func fetchPushToken() -> String {
        return ""
    }
}
