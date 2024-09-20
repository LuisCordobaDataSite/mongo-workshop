const environment = {
    "local": {
        "connectionString": "mongodb://<user>:<password>@localhost:27017"
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
    updateWidgetTypes();
}

let updateWidgetTypes = function () {
    var totalAmountOfDocuments = db.newsfeed.find({}).count();
    var result = db.newsfeed.updateMany({}, {$set: {subject: 'modified subject'}});

    print('Documents found: ' + totalAmountOfDocuments);
    print('Documents modified: ' + result.modifiedCount);
}

initiateScript();