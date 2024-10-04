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
  * _We will be using Mongo Compass in this Workshop. Feel free to use what you’re comfortable with
    
* Pull down this repo which has a folder called `mongo-workshop-2024`. This folder contains the necessary docker components for this workshop.
* Download additional sample datasets for MongoDB by pulling down this repo: https://github.com/neelabalan/mongodb-sample-dataset
  * We will specifically be using the sample_mflix movies dataset, but feel free to explore more of the sets. Each of these are provided by MongoDB and get used in MongoDB University courses.

## Workshop Steps:
### Script creation and test
1. Get your docker up and running, use the command $ docker compose up --build
2. Once you see it running in your Docker Desktop, enter the container and look for the tab 'Exec', click on it
3. In there, you are using the container's terminal. Run the command $ ls  and verify the file copyMongoAtlasUnix.sh exists, the folder scripts and indexes exist too
4. Run the command ./copyMongoAtlasUnix.sh and follow the steps required from the script
5. Once you finish the steps, you will have the collection data in your local environment to test and play around with
6. Go to the scripts folder and create a new script file with .js extension
7. Go to our github and search for a script to copy/paste from ([github link](https://github.com/MerrillCorporation/MongoDBDevOps/tree/master/dbCleanUpScriptsJS))
8. Once you copy/paste it the file you created in step 6, check the connection string, for local docker you will want a connection string like this one: "connectionString": "mongodb://<user>:<password>@localhost:27017"
9. Replace and adapt your connection string, then replace the logic with your own
10. Don't forget to add a before print statement of how your data looks before change, and a print statement of your data after, we want to know if all the documents you expect to be changed, actually changed
11. Run the script! In Docker Desktop, in the terminal of your container, run the following command $ mongosh --nodb updateDescription.js
12. Check the output statement is correct and it's what you expect
13. Overview of a real case scenario from the MongoDB Team perspective

### Index creation and test
Requirements: Localize a Database and a collection to use create the index. Get a query to test your index with.
1. Get your docker up and running, use the command $ docker compose up --build
2. Once you see it running in your Docker Desktop, enter the container and look for the tab 'Exec', click on it
3. In there, you are using the container's terminal. Run the command $ ls  and verify the file copyMongoAtlasUnix.sh exists, the folder scripts and indexes exist too
4. Run the command ./copyMongoAtlasUnix.sh and follow the steps required from the script
5. Once you finish the steps, you will have the collection data in your local environment to test and play around with
6. First create a query you will need and test it to see if it uses an colscan or indexscan
7. Create an index for that query
8. Check if the index is being used