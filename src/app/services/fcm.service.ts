import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Capacitor } from '@capacitor/core';
import { ActionPerformed, PushNotificationSchema, Token, Plumb5} from 'plumb5-sdk';


@Injectable({
  providedIn: 'root'
})
export class FcmService {

  constructor(private router: Router) { }

  public initPush() {
    if (Capacitor.getPlatform() !== 'web') {
      this.registerPush();
    }
  }

  private registerPush() {
    // Request user for permission, in real app we have to call this method in an appropriate moment for user
    // eg. when user login / details page when user subscribe for something related to push notifications
    // note: iOS will prompt user and return if they granted permission or not
    //       Android will just grant without prompting
    Plumb5.requestPermissions().then((permission) => {
      if (permission.receive === 'granted') {
        // Register with Apple / Google to receive push via APNS/FCM
        Plumb5.register();
      } else {
        // No permission for push granted
      }
    });

    // add listeners

    // On success, we should be able to receive notifications
    Plumb5.addListener(
      'registration',
      (token: Token) => {
        console.log('My token: ' + JSON.stringify(token));
      }
    );

    // Some issue with our setup and push will not work
    Plumb5.addListener(
      'registrationError',
      (error: any) => {
        console.log('Error: ' + JSON.stringify(error));
      }
    );

    // Show us the notification payload if the app is open on our device
    Plumb5.addListener(
      'pushNotificationReceived',
      async (notification: PushNotificationSchema) => {
        console.log('Push received: ' + JSON.stringify(notification));
      }
    );

    // Method called when tapping on a notification
    Plumb5.addListener(
      'pushNotificationActionPerformed',
      async (notification: ActionPerformed) => {
        const data = notification.notification.data;
        console.log('Action performed: ' + JSON.stringify(notification.notification));
        if (data.detailsId) {
          this.router.navigateByUrl(`/home/${data.detailsId}`);
        }
      }
    );
  }

}
