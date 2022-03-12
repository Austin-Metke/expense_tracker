const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const auth = admin.auth();
const firestore = admin.firestore();

exports.makeUser = functions.region('us-west2').https.onCall(async (data, context) => {

    console.log("ID: " + data.jwt);

    let idToken = data.jwt;

    //Verifies Java Web Token of user
    return await auth.verifyIdToken(idToken).then(async (claims) => {

        console.log("User verified");

        //Verifies custom claim of user to ensure they're a manager
        if ((await auth.getUser(claims.uid)).customClaims.isManager === true) {

            console.log('User is a manager');
                //Creates a user
                return await auth.createUser({
                    displayName: data.name,
                    email: data.email,
                    password: data.password,
                }).then(async (user) => {

                    const customClaims = {
                        isManager: data.isManager,
                    };
                    //Sets custom claim for user & creates document for user in firestore
                    await auth.setCustomUserClaims(user.uid, customClaims).then(() => {
                        console.log("CUSTOM CLAIM SET SUCCESSFULLY!");
                    });

                   await admin.firestore().doc('users/' + user.uid).set({
                        name: user.displayName,
                        isManager: data.isManager,
                        email: user.email,
                       phoneNumber: data.phoneNumber,
                    });

                   return 'success';

                }).catch((reason) => {

                    return reason.code;
                });
        } else {
            console.log('User is not a manager');
        }
    });
});

exports.deleteData = functions.region('us-west2').auth.user().onDelete(async (user, context) => {

    //Recursively deletes all collections under user collection
    await admin.firestore().recursiveDelete(admin.firestore().collection('users').doc(user.uid)).then(() => {

        console.log("User " + user.uid + " data was successfully deleted!");

    }).catch((reason) => {
        console.log("An error occurred deleting user data! " + reason.code);
    });

});


exports.deleteUser = functions.region('us-west2').https.onCall(async (data, context) => {

    if (await auth.getUser(context.auth.uid) !== null) {

        let idToken = data.jwt;

        return await auth.verifyIdToken(idToken).then(async (claims) => {

            if ((await auth.getUser(claims.uid)).customClaims.isManager === true) {

                return await auth.getUserByEmail(data.email).then((user) => {

                    if (user.uid === context.auth.uid) {
                        console.log("User cannot delete themself!");
                        return "can't delete self";
                    }

                    return auth.deleteUser(user.uid).then(async () => {

                        console.log("User with UID" + user.uid + "was successfully deleted!");
                        return "success";

                    }).catch((reason) => {
                        console.log("Error deleting user! " + reason.code);
                        return reason.code;

                    });

                }).catch((e) => {
                    console.log(e);
                });

            }
        });
    }
});




exports.updateUser = functions.region('us-west2').https.onCall(async (data, context) => {

    if (await auth.getUser(context.auth.uid) !== null) {

        let idToken = data.jwt;

        return await auth.verifyIdToken(idToken).then(async (claims) => {

            if ((await auth.getUser(claims.uid)).customClaims.isManager === true) {

                return auth.getUserByEmail(data.email).then((user) => {

                   return  auth.updateUser(user.uid,{
                       email: data.email,
                       password: data.password,
                       displayName: data.name,

                    }).then(async (user) => {

                       const customClaims = {
                           isManager: data.isManager,
                       };

                    //Sets custom claim for user & creates document for user in firestore
                    await auth.setCustomUserClaims(user.uid, customClaims).then(() => {
                        console.log("CUSTOM CLAIM SET SUCCESSFULLY!");
                    });

                       await admin.firestore().doc('users/' + user.uid).set({
                           name: user.displayName,
                           isManager: data.isManager,
                           email: user.email,
                           phoneNumber: data.phoneNumber,
                       });

                    console.log("User updated successfully! " + user.toJSON());
                    return "success";



                    }).catch((reason) => {

                        return reason.code

                    });
                }).catch((reason) => {
                    console.log(reason.code);
                });


            }
        });
    }
});

exports.getAllUsers = functions.region('us-west2').https.onCall(async (data, context) => {


});