const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

exports.createUserDB = functions.auth.user().onCreate((user) => {
    const logoURL = "https://www.google.pt/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png";

    const writeResult = admin.firestore().collection('users').doc(user.uid).set({maxOccu: 1, storeName: ""});
});
