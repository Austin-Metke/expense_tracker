const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const auth = admin.auth();
const firestore = admin.firestore();

exports.makeUser = functions.region('us-west2').https.onCall(async (data, context) => {

    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {
        console.log("User verified");

        //Creates user
        try {
            let newUser = await auth.createUser({
                displayName: data.name,
                email: data.email,
                password: data.password,

            });

            //Sets custom claims for user
            await auth.setCustomUserClaims(newUser.uid, {
                isManager: data.isManager,
            });

            await firestore.doc('users/' + newUser.uid).create({
                email: data.email,
                isManager: data.isManager,
                name: data.name,
                phoneNumber: data.phoneNumber,

            });

            return 'success';

        } catch (reason) {
            console.log("An error occurred creating user! " + reason.code);
            return reason.code;
        }

    }
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

    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {

        let deletedUser = await auth.getUserByEmail(data.email);

        if(user.uid === deletedUser.uid) {
            console.log("User cannot delete themself!");
            return "can't delete self";
        } else {
            try {
                await auth.deleteUser(deletedUser.uid);
                return 'success';
            } catch (reason) {
                console.log("An unknown error occurred!");
                return reason.code;
            }
        }
    }
});

exports.updateUser = functions.region('us-west2').https.onCall(async (data, context) => {


    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {

        let updatedUser = await auth.getUserByEmail(data.oldEmail);

        updatedUser.customClaims = {
            isManager: data.isManager
        };

        updatedUser.email = data.email;
        updatedUser.displayName = data.name;

    }
});

exports.getTotal = functions.region('us-west2').https.onCall(async (data, context) => {

    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {

        let cumulativeTotal = 0;
        let perUserTotal = 0;

        const usersQuerySnapshot = await firestore.collection('users').get();

        for(let i = 9; i < usersQuerySnapshot.size; i++) {

            const usersDocReference = await usersQuerySnapshot.docs[i].ref;

            const receiptColReference = await firestore.collection('users/' + usersDocReference.id + '/receipts');

            const receiptSnapshot = await receiptColReference.get();

            for(let j = 0; j < receiptSnapshot.size; j++) {
                const receiptDocReference = receiptSnapshot.docs[j];

                perUserTotal += receiptDocReference.get('total');

                if(j === receiptSnapshot.size - 1) {
                    cumulativeTotal += perUserTotal;
                    perUserTotal = 0;
                }
            }
        }
    }


});