/* eslint-disable @typescript-eslint/naming-convention */
import { Component } from '@angular/core';

import { Plumb5 } from 'plumb5-sdk';

import { Platform } from '@ionic/angular';

import { Router, NavigationStart, ActivatedRoute, Navigation, NavigationEnd } from '@angular/router';

import { FcmService } from './services/fcm.service';



@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})


export class AppComponent {
  constructor(
    private platform: Platform,
    private router: Router,
    private pageParameter: ActivatedRoute,
    private fcmService: FcmService

  ) {


    this.platform.ready().then(() => {

     this.initializeApp();


    });


  }

  initializeApp() {
    this.platform.ready().then(() => {

      // Trigger the push setup
      this.Plumb5();
      this.fcmService.initPush();
    });
  }

  Plumb5() {


    //initialize the sdk
    Plumb5.initializePlumb5();

  //initialize the sdk page tracking and in-app notfication
    this.router.events
  .subscribe(
    (event) => {
      if(event instanceof NavigationEnd) {
        console.log(event);

        Plumb5.tracking({
          ScreenName: event.url,
          PageParameter: ''
        });

        Plumb5.pushResponse({
          ScreenName: event.url,
          PageParameter: ''
        });
      }
    });

     //user details
    Plumb5.setUserDetails({
      Name: 'demo',
      EmailId: 'guru@demo.com',
      PhoneNumber: '987654321',
      LeadType: 1,
      Gender: 'Male',
      Age: '2020-01-27T06:12:01.051Z',
      AgeRange: '10-89',
      MaritalStatus: 'Married',
      Education: 'MCA',
      Occupation: 'SE',
      Interests: 'Eating',
      Location: 'Bangalore'
    });

     //Capture PushNotification Data and route navigation from notfication
    window.addEventListener('onPushNotification', (e: any) => {
      console.log('onPushNotification');
      console.log(JSON.stringify(e));
      const routeUrl = e.routeUrl;
      console.log('routeUrl', routeUrl); // similar parameter in case of route or button click
      this.router.navigate([routeUrl]);
    });

    //Event post of any kond of component
    Plumb5.eventPost({
      Type: 'Button',
      Name: 'demo@demo.com',
      PhoneNumber: '987654321',
      Value: 1,
    });

    Plumb5.notificationSubscribe();

  }



}

