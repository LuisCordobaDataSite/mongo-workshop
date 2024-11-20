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
### Required Steps:
1. Get your docker up and running, use the command $ docker compose up --build
2. Once you see it running in your Docker Desktop, enter the container and look for the tab 'Exec', click on it
3. In there, you are using the container's terminal. Run the command $ ls  and verify the file copyMongoAtlasUnix.sh exists, the folder scripts and indexes exist too ([original file is here](https://github.com/MerrillCorporation/MongoDBDevOps/blob/master/mongoUtility/copyDataToLocal/copyMongoAtlasUnix.sh))
4. Run the command ./copyMongoAtlasUnix.sh and follow the steps required from the script, info needed: dev, cluster_analytics, tagDB and newsfeed
5. Once you finish the steps, you will have the collection data in your local environment to test and play around with (we already have updateDescription.js as a guide)

### Script creation and test
1. Check the connection string, for local docker you will need a connection string like this one: "connectionString": "mongodb://localhost:27017"
2. Make a find query in your mongo terminal, you want to know how many records are going to be hit before hand so you know what to expect when the script runs.
3. Go to Compass, connect to your localhost:27017, open tagDB, you can make the query here and see the total count of results.
4. Run the script! In Docker Desktop, in the terminal of your container, run the following command $ mongosh --nodb updateDescription.js
5. Check the output statement is correct and it's what you expect
6. Overview of a real case scenario from the MongoDB Team perspective

### Index creation and test
1. Go to Docker Desktop and enter the 'Exec' tab again.
2. Let's enter our mongo terminal, type $ mongosh
3. When you enter the mongo terminal, type $ show dbs  this will show all the databases, after downloading the tagDB in the required steps (step 4), you will see in the list tagDB, enter the command $ use tagDB
4. Now you are in the tagDB workspace, type $ show collections  this will show you all the collections in the DB, you should see newsfeed if you followed the required steps (step 4)
5. Let's check the indexes in newsfeed, type $ db.newsfeed.getIndexes()  this command will list all the indexes, by default Mongo always create the _id index, the rest come from our copyMongoAtlasUnix.sh, it not only downloads the data but also gets the indexes.
6. Let's delete the indexes, type $ db.newsfeed.dropIndexes()  this will delete all indexes except _id.
7. Let's make a query and learn how to check if it's using indexes or not. Type $ db.newsfeed.find()  this query will get you all the results in the collection, this will help you visualize your data before we begin creating indexes.
8. Now run this command: $ db.newsfeed.find().explain()  this command will show all the information needed for understanding the thought process of Mongo on decisions and which decision it took with data around the results and performance. Here you care about the queryPlanner, in here there is a property called winningPlan which is the plan that Mongo decided to execute in order to run this query. Now you should see in the winningPlan, a stage attribute that says COLLSCAN*.
9. Now let's create an index, based on the collection's structure, there is a field called campaignId, let's make an index and a query for campaignId.
10. Type $ db.newsfeed.createIndex({campaignId: 1})  , this command will the index, check the notes for the meaning of 1.
11. Now let's make a query and check the explanation to see if it's using our index, type $ db.newsfeed.find({campaignId: 19020825}).explain()  (I used the value 19020825 because it's what I found when writting this workshop, use what your database has)
12. Now let's check the winningPlan, congrats, now it should show that you're using an IXSCAN.
13. Now let's check compound indexes, compound indexes are indexes that use more than 1 field, for newsfeed, we created an index only for campaignId, but if you query includes for example the scrapeDate field, will it use the index? let's check.
14. Type $ db.newsfeed.find({campaignId: 19020825, scrapeDate: ISODate("2024-05-03T06:30:16.400Z")}).explain()  , the answer is, YES, it's using the index, but why? because you already created an index for campaignId, but, will a compound index be better? let's create a compound index.
15. Type $ db.newsfeed.createIndex({campaignId: 1, scrapeDate: 1})  and now type $ db.newsfeed.find({campaignId: 19020825, scrapeDate: ISODate("2024-05-03T06:30:16.400Z")}).explain()  , now we have a winningPlan and a rejectedPlan, mongo is telling you that it considered 2 ways of getting this query, the index campaignId_1 or campaignId_1_scrapeDate_1, the winner was campaignId_1_scrapeDate_1.
16. One feature that we have with compound indexes is that it works for normal simple queries too, let's drop the campaignId index, type $ db.newsfeed.dropIndex('campaignId_1')  , now let's check our query $ db.newsfeed.find({campaignId: 19020825}).explain()  , seems like it's using our compound index! But wait, those that means you can also query for scrapeDate? let's check.
17. Type $ db.newsfeed.find({scrapeDate: ISODate("2024-05-03T06:30:16.400Z")}).explain()  , seems like no, you can't make queries for scrapeDate that use the compoundIndex, why?

*NOTES:
- COLLSCAN means that to find the results of your query, Mongo had to go through all the records in the collection, this is the worst possible plan and the less optimal.
- IXSCAN means that to find the results of your query, Mongo used an index, which is the most optimal solution, some indexes are better than others based on your query, but you're in good track.
- Index creation and the value, when you create an index, you can assign the value 1 or -1, 1 means Ascending order, this means the field values will be stored and accessed from smallest to largest. -1 means Descending order, this means the field values will be stored and accessed from largest to smallest.

1. First create a query you will need and test it to see if it uses a colscan or indexscan
  * Let's dig in into the index names. If you create an index: `db.channels.createIndex({type: -1})`, notice how instead of 1, now we have a minus 1, this means it will be descending order instead of ascending, this is particularly useful for example, if you have a field for milisecond timestamps and you always search for the newest one. Based on UNIX Timestamps, the bigger the number, the closer to the present. It makes sense to store them from bigger to smaller in the index if you constantly need to query for the earliest timestamp.
    The name for this index is: type_-1
2. Create an index for that query (if you are lost here, continue to the Real life scenario)
3. Check if the index is being used by following the next steps:
  - Use the query you created for step 6 and add at the end `.explain()`, for example: `db.channels.find().explain()`
  - Check the queryPlanner section of the output, the winningPlan.stage will say if it's a COLLSCAN or IXSCAN. COLLSCAN means it's not using an index for the query, IXSCAN means it's using an index and you should check it's using YOUR index.

Real life scenarios:
- Imagine you have a collection with 2 fields, firstName and email. If you want to query for only firstName, you should create an index for firstName. If you want to query for only email, you should create an index for email. But if you want to query for both, you can create a compound index for firstName and email. At this point you created 3 indexes but you actually only need 2. The compound index will work for queries that include both fields or the first field, for example: `db.channels.createIndex({type:1, channel: 1})` , this compound index will work for queries for type and channel together or only <b>type</b>. If you want to query for channel, you will need to create one more index.
- Now that you have created the right amount of indexes, let's check if your query is using the correct index. For the example above let's run a query, we only created the index above for type_1_channel_1 and we run a query for channel: `db.channels.find({channel: 'apiops_dev_api1690327576816902@datasite.mailinator.com'}).explain()`. What do you think it will happen, it will use an Index or not? The answer is NO! we are querying for channel but our compound index has 'type' first, the order matters!!
- How do we know it's not using an index or the correct index? if you run the example above but instead of channel you use type: `db.channels.find({type: 'email'}).explain()`, in the winningPlan section, you will have an inputStage, you not only need to check the stage for 'IXSCAN', but you can check the indexName: 'type_1_channel_1'.
Now, you can customize the names, we are exploring the standard way Mongo stores the newly created indexes, for a compound index: `db.channels.createIndex({type:1, channel: 1})`, the name will be type_1_channel_1