//
//  NotificationViewController.swift
//  fcmContent
//
//  Created by Guru Charan on 05/03/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }

    func didReceive(_ notification: UNNotification) {
        label?.text = notification.request.content.title
    }
}
