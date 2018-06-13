SERIAL="123456789523"
CREATEACTORS="NO" # Change to YES to create actors - on first launch of curl

if [ $CREATEACTORS = "YES" ] 
then
    echo "#### CREATING ACTORS ####"
    # curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "1c",    "firstName": " ", "lastName": "Pfizer", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Pleinlaan 17","city": "Brussel",  "country": "Belgium" } }' 'http://localhost:3000/api/Manufacturer'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Manufacturer",   "actorId": "2c",    "firstName": " ", "lastName": "Janssens Pharmaceutica", "role": "MANUFACTURER",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Leonardo da Vincilaan 15",  "city": "Machelen",  "country": "Belgium" } }' 'http://localhost:3000/api/Manufacturer'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Distributor",   "actorId": "3c",    "firstName": " ", "lastName": "Febelco", "role": "DISTRIBUTOR",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Eigenlostraat 1",  "city": "Sint-Niklaas",  "country": "Belgium" } }' 'http://localhost:3000/api/Distributor'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Pharmacist",   "actorId": "4c",    "firstName": " ", "lastName": "Apotheek De Lindeboom", "role": "PHARMACIST",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Antwerpsesteenweg 1",  "city": "Mechelen",  "country": "Belgium"  } }' 'http://localhost:3000/api/Pharmacist'
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.Patient",   "actorId": "5c",    "firstName": "Jonas", "lastName": "Hubert", "role": "PATIENT",   "address": {  "$class": "be.howest.bda.task2.Addres",  "street": "Jan Frans Boeckstuynsstraat 5",  "city": "Mechelen",  "country": "Belgium" } }' 'http://localhost:3000/api/Patient'
fi

echo "#### CREATING DRUG ####" 
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "be.howest.bda.task2.createDrug", "serialNumber": '${SERIAL}',  "owner": "resource:be.howest.bda.task2.Manufacturer#1F",  "manufacturer": "resource:be.howest.bda.task2.Manufacturer#1F",  "productCode": "132456",  "batchNumber": "132465", "hash": "abcdef1234567890","status": "MANUFACTURED"  }' 'http://localhost:3000/api/createDrug'
# echo "#### TRANSFER TO DISTRIBUTOR ####" 
# curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Distributor#3c",  "timestamp": "2018-06-01T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
# curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
# sleep 5
# echo ""

# echo "#### TRANSFER TO PHARMACIST ####" 
# curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Pharmacist#4c",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
# curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
# sleep 5
# echo ""

# echo "#### TRANSFER TO PATIENT ####" 
# curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Patient#5c",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
# curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}
# sleep 5
# echo ""

# echo "#### SET TO QUARANTAINE ####" 
# curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{  "$class": "be.howest.bda.task2.VerifyOrigin",  "drug": "resource:be.howest.bda.task2.Drug#'${SERIAL}'",  "newOwner": "resource:be.howest.bda.task2.Manufacturer#1c",  "timestamp": "2018-06-03T20:22:24.363Z"}' 'http://localhost:3000/api/VerifyOrigin'
# curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'${SERIAL}