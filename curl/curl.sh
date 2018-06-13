##
## Manual: set the variables as desired. 
## -> Serial: Choose a new Serial ID, unique on the blockchain. Keep it numbers only.
## -> CREATEACTORS: If you want to create new actors, for a completely new fresh run. "YES" / "NO"
## -> ID_SUFFIX: To avoid duplicate actor identities, you can add a suffix to the ID of the different actors. Ensures that they can be added to simulate a fresh run.
## -> ID_SUFFUX_PREV: For cleanup reasons. Add the ID_SUFFIX of the previous run. If invalid some errors will appear, but the script will keep working.
## -> ADMIN_CARD: network admin card

##
## Script will create the manufacter, distributor, pharmacist and patient actors on the blockchain
## will issue identities
## and start composer-rest-server's for each of these roles, to demonstrate the correct definition of the ACL.
## The creation of a drug and following trades will be simulated in order, finally also demonstrating the quarantine functionality.
##


#
# NOTE: error "EADDRINUSE" means the cleanup did not go ok. The rest-composer-server is still running from a previous run
# netstat -tulpn will list the ports in used and their processed. kill <pid> for all processes using port 3001, 3003, 3004
#
SERIAL="3334376789549"
CREATEACTORS="NO" # Change to YES to create actors - on first launch of curl
ID_SUFFIX_PREV="S"
ID_SUFFIX="AB"
ADMIN_CARD="admin@task2"
##assumes composer-rest-server running as admin on port 3000


trap cleanup EXIT

if [ $CREATEACTORS = "YES" ] 
then
    echo "#### DELETING OLD CARDS AND IDENTITIES ####"
    #composer identity revoke --card -${ID_SUFFIX_PREV}@task2 -u manufacturer-${ID_SUFFIX_PREV}
    composer card delete --card manufacturer-${ID_SUFFIX_PREV}@task2
    #composer identity revoke --card distributor-${ID_SUFFIX_PREV}@task2 -u distributor-${ID_SUFFIX_PREV}
    composer card delete --card distributor-${ID_SUFFIX_PREV}@task2
    #composer identity revoke --card pharmacist-${ID_SUFFIX_PREV}@task2 -u pharmacist-${ID_SUFFIX_PREV}
    composer card delete --card pharmacist-${ID_SUFFIX_PREV}@task2
    #composer identity revoke --card patient-${ID_SUFFIX_PREV}@task2 -u patient-${ID_SUFFIX_PREV}
    composer card delete --card patient-${ID_SUFFIX_PREV}@task2

    read -n1 -r -p "Press space to continue..." key

    echo "#### CREATING ACTORS ####"
    echo "#### CREATING MANUFACTURER ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "1'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Pfizer", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Pleinlaan 17","city": "Brussel",  "country": "Belgium" } }' 'http://localhost:3000/api/Manufacturer'
    composer identity issue -c ${ADMIN_CARD} -f manufacturer.card -u manufacturer-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Manufacturer#1${ID_SUFFIX}"
    composer card import --file manufacturer.card
        
    sleep 12

    ##not really needed...
    #curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "2'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Janssens Pharmaceutica", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Leonardo da Vincilaan 15",  "city": "Machelen",  "country": "Belgium"  } }' 'http://localhost:3000/api/Manufacturer'
    
    read -n1 -r -p "Press space to continue..." key

    echo "#### CREATING DISTRIBUTOR ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Distributor",   "actorId": "3'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Febelco", "role": "DISTRIBUTOR",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Eigenlostraat 1",  "city": "Sint-Niklaas",  "country": "Belgium" } }' 'http://localhost:3000/api/Distributor'
    composer identity issue -c ${ADMIN_CARD} -f distributor.card -u distributor-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Distributor#3${ID_SUFFIX}"
    composer card import --file distributor.card
    
    sleep 12

    read -n1 -r -p "Press space to continue..." key

    echo "#### CREATING PHARMACIST ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Pharmacist",   "actorId": "4'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Apotheek De Lindeboom", "role": "PHARMACIST",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Antwerpsesteenweg 1",  "city": "Mechelen",  "country": "Belgium"  } }' 'http://localhost:3000/api/Pharmacist'
    composer identity issue -c ${ADMIN_CARD} -f pharmacist.card -u pharmacist-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Pharmacist#4${ID_SUFFIX}"
    composer card import --file pharmacist.card
   
    sleep 12

    read -n1 -r -p "Press space to continue..." key
    
    echo "#### CREATING PATIENT ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Patient",   "actorId": "5'${ID_SUFFIX}'",    "firstName": "Jonas", "lastName": "Hubert", "role": "PATIENT",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Jan Frans Boeckstuynsstraat 5",  "city": "Mechelen",  "country": "Belgium"  } }' 'http://localhost:3000/api/Patient'
    composer identity issue -c ${ADMIN_CARD} -f patient.card -u patient-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Patient#5${ID_SUFFIX}"
    composer card import --file patient.card

   

fi
echo "#### STARTING COMPOSER_REST_SERVERS... STAND BY... ####" 
composer-rest-server -c manufacturer-${ID_SUFFIX}@task2 -p 3001 -n "never" &
manu_pid=$!
sleep 12
composer-rest-server -c distributor-${ID_SUFFIX}@task2 -p 3003 -n "never" &
distri_pid=$!
sleep 12
composer-rest-server -c pharmacist-${ID_SUFFIX}@task2 -p 3004 -n "never" &
pharma_pid=$!
sleep 12
# composer-rest-server -c patient-${ID_SUFFIX}@task2 -p 3005 -n "never" &
patient_pid=$!

sleep 5

 function cleanup {
        echo "#### CLEANUP ####" 
        kill $manu_pid
        kill $distri_pid
        kill $pharma_pid
        kill $patient_pid
    }

echo "#### CREATING DRUG ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.createDrug", "serialNumber": '${SERIAL}',  "owner": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "manufacturer": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "productCode": "132456",  "batchNumber": "132465", "hash": "abcdef1234567890","status": "MANUFACTURED"  }' 'http://localhost:3001/api/createDrug'
read -n1 -r -p "Press space to continue..." key

echo "#### TRANSFER TO DISTRIBUTOR ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Trade",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Distributor#3'${ID_SUFFIX}'",  "timestamp": "2018-06-01T20:22:24.363Z"}' 'http://localhost:3001/api/trade'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

read -n1 -r -p "Press space to continue..." key

echo "#### TRANSFER TO PHARMACIST ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Trade",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Pharmacist#4'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3003/api/trade'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

read -n1 -r -p "Press space to continue..." key

echo "#### TRANSFER TO PATIENT ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Trade",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Patient#5'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3004/api/trade'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

read -n1 -r -p "Press space to continue..." key

echo "#### SET TO QUARANTAINE ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Trade",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/trade'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}

read -n1 -r -p "Press space to continue..." key
echo "#### ALL DONE, safe to close ####" 