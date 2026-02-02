importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDE06MhNfwmleJ8VgfY9i27QIHBwoitTRY",
  appId: "1:349544989753:web:placeholder",
  messagingSenderId: "349544989753",
  projectId: "ustaad-5011f",
  authDomain: "ustaad-5011f.firebaseapp.com",
  storageBucket: "ustaad-5011f.firebasestorage.app",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
