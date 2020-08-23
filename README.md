<a href="https://imgur.com/Pxfdi6I"><img src="https://i.imgur.com/Pxfdi6I.jpg" title="source: imgur.com" /></a>

# CovidConnect

> A personal Covid-19 tracker that prioritizes user privacy. Once a user self-diagnoses, the app sends push notifications to all their contacts. 

>Tags: Covid-19, pandemic, Covid, contact tracing, CoreBluetooth, bluetooth, iOS, anonymous contact tracing, contact tracer, community, coronavirus, health, prevention, safety, cover 19 tracker

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org) 

[![INSERT YOUR GRAPHIC HERE](https://i.imgur.com/WKR5pHx.jpg)]()

---

## Table of Contents

- [Important!](#important)
- [How It Works](#howitworks)
- [Requirements](#requirements)
- [Installation](#installation)
- [Features](#features)
- [Team](#team)

---

## Important

Hey! My name is Sam, a high schooler in California. This project is a finished contact tracer that I was unable to put on the App Store, so in an effort to reach as many people as possible, I open-sourced it. I believe that CovidConnect has the potential to help many people if it becomes accessible to the public. 
**Please let me know if you can connect me to a governmental entity, hospital, insurance company, non-governmental organization, or university with which I can partner to publish the app.**

---

## HowItWorks

- users register with their email & password to obtain a personal ID
- the personal ID is assigned as the user's topic in <a href="https://firebase.google.com/docs/cloud-messaging/ios/topic-messaging" target="_blank">**Firebase Push Notification Topics**</a>
- When in close proximity, user's phones exchange ID's and subscribe to each other's topics
- When a user self-reports, a Firebase Push Notificatoin is sent to all subscribers of their topic
- Subscribers are recorded in Firebase Realtime Database
- The app only keeps track of subscriptions within 7 days. Subscriptions made 8 days ago, for example, are automatically unsubscribed and permanently deleted from the database 

---

## Requirements

- iOS 13.5
- XCode 11.6
- Apple Developer Account (for Bluetooth Low Energy and Apple Push Notification Service)

---

## Installation

- Download repository
- Install Cocoapods
- Sign with Apple Developer Account w/ Push Notifications enabled on the bundle identifier
<a href="https://imgur.com/e7MbdrP"><img src="https://i.imgur.com/e7MbdrP.png" title="source: imgur.com" /></a>

---

## Features

- Does not use the Apple/Google Framework
- multiple connections at the same time
- scan for nearby BLE devices every 3 seconds to save battery
- Keeps track of up to 2000 contacts
- Complete control over informating sharing: turn BLE on/off at the touch of a button
- No need of any records when self-diagnosing
- Only needs email to start contact tracing
- Automatic deletion of contacts

---

## Team

Just me haha. You can hit me up @ samanthasu2003@gmail.com for any questions/suggestions. 

---



