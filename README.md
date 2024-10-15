# mongo-workshop
Get a Mongo environment locally where you can follow the workshop and learn the basics of creating and testing a script and indexes in MongoDB

## Objective
> [!TIP]
> The goal of this workshop is to teach and review how to create a script in MongoDB and test it, as well as how to create an index and test it.
> We will be covering the following:
>    * Getting your Mongo locally
>    * Create a script
>    * Running the script
>    * Create an index
>    * Test the index

## Getting Started:
There are two tools we will need for this workshop. If you do not already have the following, go ahead and get these installed on your machine.

* [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Download a GUI for MongoDB](https://www.mongodb.com/try/download/compass)
  * We will be using Mongo Compass in this Workshop. Feel free to use what you’re comfortable with
    
* Pull down this repo which has a folder called `mongo-workshop-2024`. This folder contains the necessary docker components for this workshop.

## Workshop Steps:
### Script creation and test
1. Get your docker up and running, use the command $ docker compose up --build
2. Once you see it running in your Docker Desktop, enter the container and look for the tab 'Exec', click on it
3. In there, you are using the container's terminal. Run the command $ ls  and verify the file copyMongoAtlasUnix.sh exists, the folder scripts and indexes exist too ([original file is here](https://github.com/MerrillCorporation/MongoDBDevOps/blob/master/mongoUtility/copyDataToLocal/copyMongoAtlasUnix.sh))
4. Run the command ./copyMongoAtlasUnix.sh and follow the steps required from the script, info needed: dev, cluster_analytics, tagDB and newsfeed
5. Once you finish the steps, you will have the collection data in your local environment to test and play around with (we already have updateDescription.js as a guide)
6. Check the connection string, for local docker you will need a connection string like this one: "connectionString": "mongodb://*mongoadmin*:*root*@localhost:27017"
7. Replace and adapt your connection string (the user and password are not your datasite credentials, it should be the docker mongo credentials, you can find them in the docker-compose.yml for this workshop)
8. Make a find query in your mongo terminal, you want to know how many records are going to be hit before hand so you know what to expect when the script runs.
9. Go to Compass, connect to your localhost:27017, open tagDB, you can make the query here and see the total count of results.
9. Run the script! In Docker Desktop, in the terminal of your container, run the following command $ mongosh --nodb updateDescription.js
10. Check the output statement is correct and it's what you expect
11. Overview of a real case scenario from the MongoDB Team perspective

### Index creation and test
Requirements: Localize a Database and a collection to use so we can create the index. Get a query to test your index with.
1. Get your docker up and running, use the command $ docker compose up --build
2. Once you see it running in your Docker Desktop, enter the container and look for the tab 'Exec', click on it
3. In there, you are using the container's terminal. Run the command $ ls  and verify the file copyMongoAtlasUnix.sh exists, the folder scripts and indexes exist too ([original file is here](https://github.com/MerrillCorporation/MongoDBDevOps/blob/master/mongoUtility/copyDataToLocal/copyMongoAtlasUnix.sh))
4. Run the command ./copyMongoAtlasUnix.sh and follow the steps required from the script
5. Once you finish the steps, you will have the collection data in your local environment to test and play around with (we already have updateDescription.js as a guide)
6. First create a query you will need and test it to see if it uses a colscan or indexscan
  * Let's dig in into the index names. If you create an index: `db.channels.createIndex({type: -1})`, notice how instead of 1, now we have a minus 1, this means it will be descending order instead of ascending, this is particularly useful for example, if you have a field for milisecond timestamps and you always search for the newest one. Based on UNIX Timestamps, the bigger the number, the closer to the present. It makes sense to store them from bigger to smaller in the index if you constantly need to query for the earliest timestamp.
    The name for this index is: type_-1
7. Create an index for that query (if you are lost here, continue to the Real life scenario)
8. Check if the index is being used by following the next steps:
  - Use the query you created for step 6 and add at the end `.explain()`, for example: `db.channels.find().explain()`
  - Check the queryPlanner section of the output, the winningPlan.stage will say if it's a COLLSCAN or IXSCAN. COLLSCAN means it's not using an index for the query, IXSCAN means it's using an index and you should check it's using YOUR index.

Real life scenarios:
- Imagine you have a collection with 2 fields, firstName and email. If you want to query for only firstName, you should create an index for firstName. If you want to query for only email, you should create an index for email. But if you want to query for both, you can create a compound index for firstName and email. At this point you created 3 indexes but you actually only need 2. The compound index will work for queries that include both fields or the first field, for example: `db.channels.createIndex({type:1, channel: 1})` , this compound index will work for queries for type and channel together or only <b>type</b>. If you want to query for channel, you will need to create one more index.
- Now that you have created the right amount of indexes, let's check if your query is using the correct index. For the example above let's run a query, we only created the index above for type_1_channel_1 and we run a query for channel: `db.channels.find({channel: 'apiops_dev_api1690327576816902@datasite.mailinator.com'}).explain()`. What do you think it will happen, it will use an Index or not? The answer is NO! we are querying for channel but our compound index has 'type' first, the order matters!!
- How do we know it's not using an index or the correct index? if you run the example above but instead of channel you use type: `db.channels.find({type: 'email'}).explain()`, in the winningPlan section, you will have an inputStage, you not only need to check the stage for 'IXSCAN', but you can check the indexName: 'type_1_channel_1'.
Now, you can customize the names, we are exploring the standard way Mongo stores the newly created indexes, for a compound index: `db.channels.createIndex({type:1, channel: 1})`, the name will be type_1_channel_1