#! /bin/bash
#
# This script copies live mongodb data from dev/stage/prod to your local mongodb
#
# You can run this script two different ways:
# 1) user-inputted prompts -- ./copyMongoAtlasUnix.sh
# 2) command-line arguments -- ./copyMongoAtlasUnix.sh -en <environment> -cl <cluster> -db <database> -co <collection>
#
# You can copy data at different levels of granularity for environment + dataset:
# 1) no database + no collection => copy all databases and collections
# 2) individual database + no collection => copy all collections from individual database
# 3) individual database + individual collection => copy individual collection from individual database



##### Functions

function createMongoDataDirectory {
fileformat=unix
current_dir=$(pwd)
BASEDIR=$(dirname $0)
if [ $BASEDIR = '.' ]; then
    BASEDIR="$current_dir"
fi
mkdir -p $BASEDIR/tmp
}


function displayHelpNotes {
clear
echo
echo "MongoDB data is stored at $BASEDIR/tmp and is overwritten each time this script is ran"
echo "Large databases and collections can take a half hour or more to copy i.e., docMetadata, userDetails, projects"
echo "Press control + c at any time to immediately stop a particular operation"
echo "Press return at each prompt to use default value"
echo "User-inputted values are case sensitive i.e., use dev not DEV/Dev"
echo "User must be connected to VPN"
echo
}


function getEnvironment {
echo
read -p "Enter environment (default is dev):
dev
stage
prod
prodUS
prodEU
prodAU
---------
" ENVIRONMENT
if [ -z "$ENVIRONMENT" ]; then
    ENVIRONMENT="dev"
fi
}

function validateEnvironment {
case $ENVIRONMENT in
    dev | stage | prod |prodUS | prodEU | prodAU)
        ;;
    *)
        echo
        echo "invalid environment so aborting"
        exit 1
esac
}

function getCluster {
echo
read -p "please choose cluster from below list(default is cluster-projects):
------- global clusters ---------
cluster-billing
cluster-analytics
cluster-users
cluster-projects
cluster-userscrm
------- regional clusters --------
cluster-blob
cluster-comments
cluster-documents
cluster-notification
cluster-drm
cluster-acquire
cluster-questionAnswer
cluster-redaction
cluster-smarttools
cluster-outreach
------------------
" CLUSTER
   if [ -z "$CLUSTER" ]; then
        CLUSTER="cluster-projects"
    fi
#fi
}

function validateCluster {
case $CLUSTER in
    cluster-billing | cluster-analytics | cluster-users | cluster-projects | cluster-userscrm)
        DATASET="global"
        ;;
    cluster-blob | cluster-comments | cluster-documents |cluster-notification | cluster-drm | cluster-acquire | cluster-questionAnswer | cluster-redaction |cluster-smarttools | cluster-outreach)
        DATASET="regional"
        ;;
    *)
        echo
        echo "invalid cluster so aborting"
        exit 1
esac
}

a=1
flag=0
function getUsername {
  while [ $a -lt 4 ]
  do
echo
read -p "enter your datasite email address :
" USERNAME
echo "---------------";

if  [ -z "$USERNAME" ]; then
   echo "!! $a attempt, email address is empty, please enter valid email address "
   a=`expr $a + 1`
   getUsername
elif [[ "$USERNAME" =~ (^[a-zA-Z\*\.-]+@datasite.com)$ ]]; then
  flag=1;
  break
else
    echo "!! $a attempt, email address $USERNAME is invalid."
    a=`expr $a + 1`
    getUsername
fi
  done
if [ $flag == 1 ]; then
   getPassword
else
   echo
    echo "!! oops, attempted invalid email address 3 times so aborting"
    exit 1
fi
}

function getPassword {
  echo
  echo "enter your datasite password: "
    stty -echo
  read PASSWORD;
  stty echo
echo "----------------";
if [ -z "$PASSWORD" ]; then
   echo "!! hey you forgot to enter the password, please try again "
   getPassword
fi
}

function getPortNumber {
    echo
    echo "enter local mongodb port number (default will be 27017): "
    read PORT
    if [ -z "$PORT" ]; then
        PORT=27017
    fi
    echo "-----------------"
}

function getHostname {
    getClusterNode
    HOSTNAME="$CLUSTER-pl-0.$CLUSTER_NODE.mongodb.net"
}
function getClusterNode {
if [ "$ENVIRONMENT" == "dev" ] && [ "$DATASET" == "global" ]; then
    CLUSTER_NODE="l2dhp"
elif [ "$ENVIRONMENT" == "stage" ] && [ "$DATASET" == "global" ]; then
    CLUSTER_NODE="wzn4q"
elif [ "$ENVIRONMENT" == "prod" ] && [ "$DATASET" == "global" ]; then
    CLUSTER_NODE="yervh"
elif [ "$ENVIRONMENT" == "dev" ] && [ "$DATASET" == "regional" ]; then
    if [ "$CLUSTER" == "cluster-acquire" ]; then
       CLUSTER_NODE="d9wgi.azure" # should be renamed to be consistent
    else
       CLUSTER_NODE="d9wgi"
    fi
elif [ "$ENVIRONMENT" == "stage" ] && [ "$DATASET" == "regional" ]; then
    CLUSTER_NODE="45bpg"
elif [ "$ENVIRONMENT" == "prodUS" ] && [ "$DATASET" == "regional" ]; then
    CLUSTER_NODE="pqxnd"
elif [ "$ENVIRONMENT" == "prodEU" ] && [ "$DATASET" == "regional" ]; then
    CLUSTER_NODE="viiuc"
elif [ "$ENVIRONMENT" == "prodAU" ] && [ "$DATASET" == "regional" ]; then
    CLUSTER_NODE="rvzgo"
fi
}

function getAllDatabasesForHostname {
index=0
DATABASES=()
DATABASES_JSON=$(mongosh "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN"  -u $USERNAME -p $PASSWORD  --quiet --eval "printjson(db.getMongo().getDBNames())")
if [ "$DATABASE_JSON" == \*AuthenticationFailed\* ]; then
      echo
      echo "invalid credentials so aborting"
      exit 1
fi
for CURRENT_DATABASE in ${DATABASES_JSON[0]}; do
    if [ "$CURRENT_DATABASE" == "[" ] || [ "$CURRENT_DATABASE" == "]" ]; then
        continue
    fi
    if [[ $CURRENT_DATABASE = \"config\"* ]] || [[ $CURRENT_DATABASE = \"admin\"* ]] || [[ $CURRENT_DATABASE = \"local\"* ]] ; then
        continue
    fi
    if [ "${CURRENT_DATABASE: -1}" == "," ]; then
        CURRENT_DATABASE=$(echo $CURRENT_DATABASE | cut -c2- | rev | cut -c3- | rev)
    else
        CURRENT_DATABASE=$(echo $CURRENT_DATABASE | cut -c2- | rev | cut -c2- | rev)
    fi
    DATABASES[index]=$CURRENT_DATABASE
    index=$(expr $index + 1)
done
}

function getDatabase {
echo
echo "---------"
echo "${#DATABASES[@]} databases in $ENVIRONMENT $DATASET $CLUSTER:"
for CURRENT_DATABASE in "${DATABASES[@]}"; do
    echo "$CURRENT_DATABASE"
done
echo
read -p "Database to copy (leave blank for all):
" DATABASE
}

function validateDatabase {
databaseFound=
for CURRENT_DATABASE in "${DATABASES[@]}"; do
    if [ "$CURRENT_DATABASE" == "$DATABASE" ]; then
        databaseFound=$CURRENT_DATABASE
        break
    fi
done
if [ -z "$databaseFound" ]; then
    echo
    echo "invalid database so aborting"
    exit 1
fi
}


function getAllCollectionsForDatabase {
index=0
COLLECTIONS=()
COLLECTIONS_JSON=$(mongosh  "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN"  -u $USERNAME -p $PASSWORD --quiet --eval "db.getCollectionNames()")
if [ "$COLLECTIONS_JSON" == \*AuthenticationFailed\* ]; then
      echo
       echo "invalid credentials so aborting"
       exit 1
fi
for CURRENT_COLLECTION in ${COLLECTIONS_JSON[0]}; do
    if [ "$CURRENT_COLLECTION" == "[" ] || [ "$CURRENT_COLLECTION" == "]" ]; then
        continue
    fi
    if [[ $CURRENT_COLLECTION = \"system.profile\"* ]]; then
        continue
    fi
    if [ "${CURRENT_COLLECTION: -1}" == "," ]; then
        CURRENT_COLLECTION=$(echo $CURRENT_COLLECTION | cut -c2- | rev | cut -c3- | rev)
    else
        CURRENT_COLLECTION=$(echo $CURRENT_COLLECTION | cut -c2- | rev | cut -c2- | rev)
    fi
    COLLECTIONS[index]=$CURRENT_COLLECTION
    index=$(expr $index + 1)
done
}

function getCollection {
echo
echo "${#COLLECTIONS[@]} collections in $DATABASE:"
for CURRENT_COLLECTION in "${COLLECTIONS[@]}"; do
    documentCount=$(mongosh  "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN"  -u $USERNAME -p $PASSWORD --quiet --eval "db.getCollection(\"$CURRENT_COLLECTION\").countDocuments()")
    echo "$CURRENT_COLLECTION ($documentCount documents)"
done
echo
read -p "Collection to copy (leave blank for all):
" COLLECTION
}

function validateCollection {
collectionFound=
for CURRENT_COLLECTION in "${COLLECTIONS[@]}"; do
    if [ "$CURRENT_COLLECTION" == "$COLLECTION" ]; then
        collectionFound=$CURRENT_COLLECTION
        break
    fi
done
if [ -z "$collectionFound" ]; then
    echo
    echo "invalid collection so aborting"
    exit 1
fi
}


function copyEveryDatabaseAndCollection {
echo
echo "copying every database and collection on $ENVIRONMENT $DATASET $CLUSTER"
echo
for CURRENT_DATABASE in "${DATABASES[@]}"; do
    mongodump --uri "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN"  -d $CURRENT_DATABASE -u $USERNAME -p $PASSWORD --out $BASEDIR/tmp/ --excludeCollection system.profile
    echo
    echo "!!! hurray dumping complete, now restoring the data to your localhost"
    echo
    mongorestore -h localhost:$PORT -d $CURRENT_DATABASE --drop $BASEDIR/tmp/$CURRENT_DATABASE/ -u mongoadmin -p root
    echo
    echo "!! restore completed"
done
}

function copyEveryCollectionFromIndividualDatabase {
echo
echo "copying every collection from database $DATABASE on $ENVIRONMENT $DATASET $CLUSTER"
echo
mongodump --uri "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN" -d $DATABASE  -u $USERNAME -p $PASSWORD  --out $BASEDIR/tmp/ --excludeCollection system.profile
echo
echo "!!! hurray dumping complete, now restoring the data to your localhost"
echo
mongorestore -h localhost:$PORT -d $DATABASE --drop $BASEDIR/tmp/$DATABASE/ -u mongoadmin -p root
echo
echo "!! restore completed"
}

function copyIndividualCollectionFromIndividualDatabase {
echo
echo "copying collection $COLLECTION from database $DATABASE on $ENVIRONMENT $DATASET $CLUSTER"
echo
mongodump --uri "mongodb+srv://$HOSTNAME/$DATABASE?readPreference=secondaryPreferred&authSource=%24external&authMechanism=PLAIN" -d $DATABASE -c $COLLECTION  -u $USERNAME -p $PASSWORD --out $BASEDIR/tmp/
echo
echo "!!! hurray dumping complete, now restoring the data to your localhost"
echo
# if you use mongodb locally, use the line below
# mongorestore -h localhost:$PORT -d $DATABASE -c $COLLECTION --drop $BASEDIR/tmp/$DATABASE/$COLLECTION.bson -u mongoadmin -p root
# if you use mongo in docker, use the line below with your corresponding credentials
mongorestore --uri "mongodb://mongoadmin:root@localhost:$PORT/$DATABASE?authSource=admin" -d $DATABASE -c $COLLECTION --drop $BASEDIR/tmp/$DATABASE/$COLLECTION.bson
echo
echo "!! restore completed"
}



##### Main

createMongoDataDirectory
displayHelpNotes

if [ $# -eq 0 ]; then
    getEnvironment
    validateEnvironment
    getCluster
    validateCluster
    getHostname
    getUsername
    getPortNumber
    getAllDatabasesForHostname
    getDatabase
    if [[ -z "$DATABASE" ]]; then
        copyEveryDatabaseAndCollection
    else
        validateDatabase
        getAllCollectionsForDatabase
        getCollection
        if [[ -z "$COLLECTION" ]]; then
            copyEveryCollectionFromIndividualDatabase
        else
            validateCollection
            copyIndividualCollectionFromIndividualDatabase
        fi
    fi
else
    while [ "$1" != "" ]; do
        case $1 in
            -en)
                shift
                ENVIRONMENT=$1
                ;;
            -cl)
                shift
                CLUSTER=$1
                ;;
            -db)
                shift
                DATABASE=$1
                ;;
            -co)
                shift
                COLLECTION=$1
                ;;
        esac
        shift
    done
    if [[ -z "$ENVIRONMENT" ]]; then
        getEnvironment
    fi
    validateEnvironment
    if [[ -z "$CLUSTER" ]]; then
            getCluster
    fi
    validateCluster
    getHostname
    getUsername
    getPortNumber
    getAllDatabasesForHostname
    if [[ -z "$DATABASE" ]] && [[ -z "$COLLECTION" ]]; then
        copyEveryDatabaseAndCollection
    elif [[ -z "$COLLECTION" ]]; then
        validateDatabase
        copyEveryCollectionFromIndividualDatabase
    elif [[ -z "$DATABASE" ]]; then
        echo
        echo "invalid database so aborting"
        exit 1
    else
        validateDatabase
        getAllCollectionsForDatabase
        validateCollection
        copyIndividualCollectionFromIndividualDatabase
    fi
fi
