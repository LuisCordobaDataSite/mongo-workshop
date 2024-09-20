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

## Troubleshooting Notes:
<details>
  <summary>Need a fresh start with your mongo data?</summary>

  * Delete the mongo volumes in Docker Desktop
    * Make sure you 🛑 _Stop_ 🛑 your docker containers first
    *  _Delete_ the mongo containers `[mongo-node1, mongo-node2, mongo-node3]`
      ![image](https://github.com/samifrank/mongodb-kafka-workshop/assets/84085490/a131d831-d295-4364-b887-7b9de2ec7b30)
    * _Delete_ the mongo volumes
    
      ![image](https://github.com/samifrank/mongodb-kafka-workshop/assets/84085490/4c28d09b-d39d-4543-a155-78316c7189d8)
</details>

<details>
  <summary>Docker containers not spinning up?</summary>

  * If you are seeing an error message like the following:
    ![image (2)](https://github.com/user-attachments/assets/de9a20bd-0db2-450f-99e0-4b4ba6977fba)

  * Check if you are signed into Docker Desktop. If you are logged in - **log out**
      
</details>

