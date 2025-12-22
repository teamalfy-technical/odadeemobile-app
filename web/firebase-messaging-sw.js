// Prevent service worker from causing hot reload on visibility change
self.addEventListener('install', (event) => {
  console.log('Service Worker installing - skip waiting');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('Service Worker activating - claiming clients');
  event.waitUntil(self.clients.claim());
});

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Firebase configuration from firebase_options.dart (web platform)
firebase.initializeApp({
  apiKey: "AIzaSyBozqSCK5q1uhSDPcudjokUB3i4D_pByIA",
  authDomain: "odadee-e78e4.firebaseapp.com",
  projectId: "odadee-e78e4",
  storageBucket: "odadee-e78e4.firebasestorage.app",
  messagingSenderId: "582465997326",
  appId: "1:582465997326:web:b5ad0fcef4d002b24eca5f",
  measurementId: "G-962HRMB9DY"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/ic_launcher.png',
    badge: '/icons/ic_launcher.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
