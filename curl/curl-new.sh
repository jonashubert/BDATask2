SERIAL="1234567895"
CREATEACTORS="YES" # Change to YES to create actors - on first launch of curl
ID_SUFFIX="J"
ADMIN_CARD="admin@task2"
##assumes composer-rest-server running as admin on port 3000

if [ $CREATEACTORS = "YES" ] 
then
    echo "#### DELETING OLD CARDS AND IDENTITIES ####"
    composer identity revoke --card manufacturer@task2 -u manufacturer${ID_SUFFIX}
    composer card delete --card manufacturer@task2
    composer identity revoke --card distributor@task2 -u distributor${ID_SUFFIX}
    composer card delete --card distributor@task2
    composer identity revoke --card pharmacist@task2 -u pharmacist${ID_SUFFIX}
    composer card delete --card pharmacist@task2
    composer identity revoke --card patient@task2 -u patient${ID_SUFFIX}
    composer card delete --card patient@task2

    echo "#### CREATING ACTORS ####"
    echo "#### CREATING MANUFACTURER ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "1'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Pfizer", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Pleinlaan 17","city": "Brussel",  "country": "Belgium",   "id": "qsdfezra"  } }' 'http://localhost:3000/api/Manufacturer'
    composer identity issue -c ${ADMIN_CARD} -f manufacturer.card -u manufacturer-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Manufacturer#1${ID_SUFFIX}"
    composer card import --file manufacturer.card
    composer-rest-server -c manufacturer-${ID_SUFFIX}@task2 -p 3001 -n "never" &
    manu_pid=$!
    echo "RUNNING ON ..." + $manu_pid
    ##not really needed...
    #curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "2'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Janssens Pharmaceutica", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Leonardo da Vincilaan 15",  "city": "Machelen",  "country": "Belgium",   "id": "faezrarez"  } }' 'http://localhost:3000/api/Manufacturer'

    echo "#### CREATING DISTRIBUTOR ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Distributor",   "actorId": "3'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Febelco", "role": "DISTRIBUTOR",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Eigenlostraat 1",  "city": "Sint-Niklaas",  "country": "Belgium",   "id": "sdqsfqdsfs"  } }' 'http://localhost:3000/api/Distributor'
    composer identity issue -c ${ADMIN_CARD} -f distributor.card -u distributor-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Distributor#3${ID_SUFFIX}"
    composer card import --file distributor.card
    composer-rest-server -c distributor-${ID_SUFFIX}@task2 -p 3003 -n "never" &
    distri_pid=$!
    echo "RUNNING ON ..." + $distri_pid

    echo "#### CREATING PHARMACIST ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Pharmacist",   "actorId": "4'${ID_SUFFIX}'",    "firstName": " ", "lastName": "Apotheek De Lindeboom", "role": "PHARMACIST",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Antwerpsesteenweg 1",  "city": "Mechelen",  "country": "Belgium",   "id": "aazerza"  } }' 'http://localhost:3000/api/Pharmacist'
    composer identity issue -c ${ADMIN_CARD} -f pharmacist.card -u pharmacist-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Pharmacist#4${ID_SUFFIX}"
    composer card import --file pharmacist.card
    composer-rest-server -c pharmacist-${ID_SUFFIX}@task2 -p 3004 -n "never" &
    pharma_pid=$!
    echo "RUNNING ON ..." + $pharma_pid

    echo "#### CREATING PATIENT ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Patient",   "actorId": "5'${ID_SUFFIX}'",    "firstName": "Jonas", "lastName": "Hubert", "role": "PATIENT",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Jan Frans Boeckstuynsstraat 5",  "city": "Mechelen",  "country": "Belgium",   "id": "dfsgdfsghgh"  } }' 'http://localhost:3000/api/Patient'
    composer identity issue -c ${ADMIN_CARD} -f patient.card -u patient-${ID_SUFFIX} -a "resource:be.howest.bda.task2.Patient#5${ID_SUFFIX}"
    composer card import --file patient.card
    composer-rest-server -c patient-${ID_SUFFIX}@task2 -p 3005 -n "never" &
    patient_pid=$!
    echo "RUNNING ON ..." + $patient_pid
fi

echo "#### CREATING DRUG ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Drug",  "serialNumber": '${SERIAL}',  "owner": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "manufacturer": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "productCode": "987654322",  "batchNumber": "987123564",  "hash": "abcdef1234567890",  "status": "MANUFACTURED"}' 'http://localhost:3001/api/Drug'

echo "#### TRANSFER TO DISTRIBUTOR ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Distributor#3'${ID_SUFFIX}'",  "timestamp": "2018-06-01T20:22:24.363Z"}' 'http://localhost:3001/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### TRANSFER TO PHARMACIST ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Pharmacist#4'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3002/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### TRANSFER TO PATIENT ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Patient#5'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3003/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### SET TO QUARANTAINE ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Manufacturer#1'${ID_SUFFIX}'",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}


echo "#### CLEANUP ####" 
kill $manu_pid
kill $distri_pid
kill $pharma_pid
kill $patient_pid

echo "#### ALL DONE, safe to close ####" 