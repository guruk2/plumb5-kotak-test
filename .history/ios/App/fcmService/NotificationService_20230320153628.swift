

import UIKit
import UserNotifications

public enum MediaType: String {
    case image
    case gif
    case video
    case audio
}

private struct Media {
    private var data: Data
    private var ext: String
    private var type: MediaType

    init(forMediaType mediaType: MediaType, withData data: Data, fileExtension ext: String) {
        type = mediaType
        self.data = data
        self.ext = ext

    }

    var attachmentOptions: [String: Any?] {
        switch type {
        case .image:
            return [UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.50).dictionaryRepresentation]
        case .gif:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .video:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .audio:
            return [UNNotificationAttachmentOptionsThumbnailHiddenKey: 1]
        }
    }

    var fileIdentifier: String {
        return type.rawValue
    }

    var fileExt: String {
        if ext.count > 0 {
            return ext
        } else {
            switch type {
            case .image:
                return "jpg"
            case .gif:
                return "gif"
            case .video:
                return "mp4"
            case .audio:
                return "mp3"
            }
        }
    }

    var mediaData: Data? {
        return data
    }
}

// @available(iOSApplicationExtension 10.0, *)
private extension UNNotificationAttachment {
    static func create(fromMedia media: Media) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = "\(media.fileIdentifier).\(media.fileExt)"
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)

            guard let data = media.mediaData else {
                return nil
            }

            try data.write(to: fileURL)
            return create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: media.attachmentOptions as [String: Any])
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }

    static func create(fileIdentifier: String, fileUrl: URL, options: [String: Any]? = nil) -> UNNotificationAttachment? {
        var n: UNNotificationAttachment?
        do {
            n = try UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        return n
    }
}

private func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}

private func loadAttachment(forMediaType mediaType: MediaType, withUrlString urlString: String, completionHandler: (UNNotificationAttachment?) -> Void) {
    guard let url = resourceURL(forUrlString: urlString) else {
        completionHandler(nil)
        return
    }

    do {
        let data = try Data(contentsOf: url)
        let media = Media(forMediaType: mediaType, withData: data, fileExtension: url.pathExtension)
        if let attachment = UNNotificationAttachment.create(fromMedia: media) {
            completionHandler(attachment)
            return
        }
        completionHandler(nil)
    } catch {
        print("error " + error.localizedDescription)
        completionHandler(nil)
    }
}

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        registerCategory(data: request.content.userInfo)
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...

            let userInfo = bestAttemptContent.userInfo
            // check for a media attachment
            if (userInfo["attachment_url"] as? String) != "" {
                guard

                    let url = userInfo["attachment_url"] as? String,
                    let _mediaType = userInfo["media_type"] as? String,
                    let mediaType = MediaType(rawValue: _mediaType)
                else {
                    contentHandler(bestAttemptContent)
                    return
                }

                loadAttachment(forMediaType: mediaType, withUrlString: url, completionHandler: { attachment in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }

                    contentHandler(bestAttemptContent)
                })
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    func registerCategory(data: [AnyHashable: Any]) {
        let title: String = (data["title"] as! String).replacingOccurrences(of: "~A~", with: "&")
        let message: String = (data["message"] as! String).replacingOccurrences(of: "~A~", with: "&")
        let workflowdataId: String = (data["workflowdataId"] as! String)
        let P5UniqueId: String = (data["P5UniqueId"] as! String)
        let nExtraAction: String = (data["extraaction"] as! String)
        let nclkAction: String = (data["clickaction"] as! String)
        let atitle: [String] = (title.components(separatedBy: "^"))

        if nExtraAction != "" {


            var pushAction: [PushNotificationCategory] = []
            var pushButtonn: [PushNotificationAction] = []
            if nExtraAction.count > 0 {
                let btnText: [String] = nExtraAction.components(separatedBy: "|")
                for obj in btnText {
                    if obj != "" {
                        let bValue: [String] = obj.components(separatedBy: "^")
                        let bName: String = bValue[0]
                        //                    let bImageId:String = bValue[1]
                        let bAction: String = bValue[2]
                        let bParm: String = bValue[3]
                        //                    let bExtra:String = bValue[4]
                        let bIdentifier: String = "btn" + "^" + bAction + "^" + bParm
                        pushButtonn.append(PushNotificationAction(button_title: bName, identifier: bIdentifier))
                    }
                }
                pushAction.append(PushNotificationCategory(name: "P5pushAction", pushAction: pushButtonn))
                registerPushNotificationCategories(categories: pushAction) { t in
                    print(t)
                }
            }
        }
    }

    func registerPushNotificationCategories(categories: [PushNotificationCategory]?, completionHandler: @escaping (Bool) -> Void) {
        guard let categories = categories else {
            if #available(iOS 10.0, *) {
                let notificationCategories = Set<UNNotificationCategory>()
                UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
            } else {
                // Fallback on earlier versions
            }
            return
        }
        if #available(iOS 10.0, *) {
            var notificationCategories = Set<UNNotificationCategory>()
            for category in categories {
                var actionList = [UNNotificationAction]()
                for action in category.pushActions! {
                    let action = UNNotificationAction(identifier: action.identifier!, title: action.button_title!, options: [.foreground])
                    actionList.append(action)
                }
                let category = UNNotificationCategory(identifier: category.name!, actions: actionList, intentIdentifiers: [], options: [])
                notificationCategories.insert(category)
            }
            UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
            UNUserNotificationCenter.current().getNotificationCategories(completionHandler: { _ in
                completionHandler(true)
            })
        } else {}
    }
}

struct PushNotificationCategory {
    var name: String?
    var pushActions: [PushNotificationAction]?

    init(name: String?, pushAction: [PushNotificationAction]?) {
        self.name = name
        pushActions = pushAction
    }
}

struct PushNotificationAction: Codable {
    var button_title: String?
    var identifier: String?

    init(button_title: String?, identifier: String?) {
        self.button_title = button_title
        self.identifier = identifier
    }
}
