SERIAL="1234567894"
CREATEACTORS="YES" # Change to YES to create actors - on first launch of curl

if [ $CREATEACTORS = "YES" ] 
then
    echo "#### CREATING ACTORS ####"
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Actor",   "actorId": "1",    "firstName": " ", "lastName": "Pfizer", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Pleinlaan 17","city": "Brussel",  "country": "Belgium",   "id": "qsdfezra"  } }' 'http://localhost:3000/api/Actor'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Actor",   "actorId": "2",    "firstName": " ", "lastName": "Janssens Pharmaceutica", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Leonardo da Vincilaan 15",  "city": "Machelen",  "country": "Belgium",   "id": "faezrarez"  } }' 'http://localhost:3000/api/Actor'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Actor",   "actorId": "3",    "firstName": " ", "lastName": "Febelco", "role": "DISTRIBUTOR",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Eigenlostraat 1",  "city": "Sint-Niklaas",  "country": "Belgium",   "id": "sdqsfqdsfs"  } }' 'http://localhost:3000/api/Actor'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Actor",   "actorId": "4",    "firstName": " ", "lastName": "Apotheek De Lindeboom", "role": "PHARMACIST",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Antwerpsesteenweg 1",  "city": "Mechelen",  "country": "Belgium",   "id": "aazerza"  } }' 'http://localhost:3000/api/Actor'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Actor",   "actorId": "5",    "firstName": "Jonas", "lastName": "Hubert", "role": "PATIENT",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Jan Frans Boeckstuynsstraat 5",  "city": "Mechelen",  "country": "Belgium",   "id": "dfsgdfsghgh"  } }' 'http://localhost:3000/api/Actor'
fi

echo "#### CREATING DRUG ####" 
#curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.Drug",  "serialNumber": '${SERIAL}',  "owner": "resource:be.howest.bda.task2.Actor#1",  "manufacturer": "resource:be.howest.bda.task2.Actor#1",  "productCode": "987654322",  "batchNumber": "987123564",  "hash": "abcdef1234567890",  "status": "MANUFACTURED"}' 'http://localhost:3000/api/Drug'

echo "#### TRANSFER TO DISTRIBUTOR ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Actor#3",  "timestamp": "2018-06-01T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### TRANSFER TO PHARMACIST ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Actor#4",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### TRANSFER TO PATIENT ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Actor#5",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
sleep 5
echo ""

echo "#### SET TO QUARANTAINE ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Actor#1",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}