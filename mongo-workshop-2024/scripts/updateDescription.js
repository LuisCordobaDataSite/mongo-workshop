const environment = {
    "local": {
        "connectionString": "mongodb://localhost:27017"
    },
    // "dev": {
    //     "connectionString": "mongodb+srv://<user>:<password>@cluster-users-pl-0.l2dhp.mongodb.net/userDetails?maxIdleTimeMS=60000&authSource=admin&ssl=true"
    // },
    // "stage": {
    //     "connectionString": "mongodb+srv://<user>:<password>@cluster-users-pl-0.wzn4q.mongodb.net/userDetails?maxIdleTimeMS=60000&authSource=admin&ssl=true"
    // },
    // "prod": {
    //     // "connectionString": "mongodb+srv://<user>:<password>@cluster-users-pl-0.yervh.mongodb.net/userDetails?maxIdleTimeMS=60000&authSource=admin&ssl=true"
    // }
}

let db;
let primaryMongo
let envVal = 'local';

let connectToDb = function () {
    primaryMongo = new Mongo(environment[envVal]["connectionString"]);
    db = primaryMongo.getDB("tagDB");
}

let initiateScript = function () {
    connectToDb();
    updateMany();
    // updateWithBulkWrite();
    // updateWithUpdateOne();
}

const subjectToChange = 'modified subject1';

let updateMany = function () {
    let totalAmountOfDocuments = db.newsfeed.find({}).count();
    // We update everything that matches the selection
    let result = db.newsfeed.updateMany({}, {$set: {subject: subjectToChange}});

    print('Documents found: ' + totalAmountOfDocuments);
    print('Documents modified: ' + result.modifiedCount);
    print('Script successfully executed? ' + (totalAmountOfDocuments === result.modifiedCount));
}

let updateWithBulkWrite = function () {
    let totalAmountOfDocuments = db.newsfeed.find({}).count();
    // The find returns a cursor, we turn the cursor into an Array with toArray, then
    // we map through the elements and return an object with the command name, filter and update
    const bulkOps = db.newsfeed.find().toArray().map(doc => {
        return {
            updateOne: {
                filter: { _id: doc._id },
                update: { $set: { subject: subjectToChange } }
            }
        };
    });
    
    const result = db.newsfeed.bulkWrite(bulkOps);

    print('Documents found: ' + totalAmountOfDocuments);
    print('Documents modified: ' + result.modifiedCount);
    print('Script successfully executed? ' + (totalAmountOfDocuments === result.modifiedCount));
}

let updateWithUpdateOne = function () {
    let totalAmountOfDocuments = db.newsfeed.find().count();
    // We get the cursor
    const cursor = db.newsfeed.find();
    let documentModifiedCount = 0;

    // Loop through each value
    cursor.forEach(async (e) => {
        const result = await db.newsfeed.updateOne({ _id: e._id }, { $set: { subject: subjectToChange } });
        if (result.modifiedCount > 0) {
            documentModifiedCount += result.modifiedCount;
        }
    });

    print('Documents found: ' + totalAmountOfDocuments);
    print('Documents modified: ' + documentModifiedCount);
    print('Script successfully executed? ' + (totalAmountOfDocuments === documentModifiedCount));
}

initiateScript();