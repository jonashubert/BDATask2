/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
/**
 * Write your transction processor functions here
 */

/**
 * transaction verifies origin of the drug, trades if it's a legal trade. Will quarantine drug if it's not.
 * @param {be.howest.bda.task2.Trade} trade
 * @transaction
 */
async function tradeDrug(trade) {
    console.log("myLog: verifing drug...");
    let factory = getFactory();
    let NS = "be.howest.bda.task2";
    console.log("myLog: oldOwner: " + trade.drug.owner.firstName + " " + trade.drug.owner.lastName + " : " + trade.drug.owner.role);
    let ownerRole = trade.drug.owner.role;
    let drugState = trade.drug.status;
    console.log("myLog: newOwner: "+  trade.newOwner.getIdentifier());
    let participantRegistery = await getParticipantRegistry(trade.newOwner.getFullyQualifiedType());
    trade.drug.owner = factory.newRelationship(trade.newOwner.getNamespace(),trade.newOwner.getType(), trade.newOwner.getIdentifier());
    let newOwner = await participantRegistery.get(trade.newOwner.getIdentifier());

    

    console.log("myLog: newOwner: " + newOwner);
    let newOwnerRole = newOwner.role; 

    if (ownerRole == "MANUFACTURER" && drugState== "MANUFACTURED" && newOwnerRole == "DISTRIBUTOR") {
        trade.drug.status = "DISTRIBUTING";
        console.log("myLog: Status set as DISTRIBUTED");
    }
    else if (ownerRole == "DISTRIBUTOR" && drugState== "DISTRIBUTING" && newOwnerRole == "PHARMACIST") {
        trade.drug.status = "LOCAL_STOCK";
        console.log("myLog: Status set as LOCAL STOCK");
    }
    else if (ownerRole == "PHARMACIST" && drugState== "LOCAL_STOCK" && newOwnerRole == "PATIENT") {
        trade.drug.status = "SOLD";
        console.log("myLog: Status set as SOLD");
    }
    else {
        trade.drug.status = "QUARANTINE";
        console.log("myLog: Status set as QUARANTINE");
        const drugs = await query('selectAllDrugsBySerial', {'serial': trade.drug.serialNumber});
        if (drugs.length >= 1) {
            const factory = getFactory();
            const drugsToQuarantaine = drugs.filter(function (drug) {
                return drugs.status  != "QUARANTINE";
            });
            for (let x = 0; x < drugsToQuarantaine.length; x++) {
                drugsToQuarantaine[x].status = 'QUARANTINE';
                const quarantineDrugEvent = factory.newEvent(NS, 'QuarantineDrugEvent');
                quarantineDrugEvent.drug = drugsToQuarantaine[x];
                emit (quarantineDrugEvent);
            }
            let assetRegistery = await getAssetRegistry(NS + '.Drug');
            await assetRegistery.updateAll(drugsToQuarantaine);
        }
    }

    let temp = trade.drug.serialNumber + trade.drug.productCode + trade.drug.batchNumber + trade.drug.manufacturer; 
    let newhash = Sha256.hash(temp,{});
    let oldhash = trade.drug.hash;


    if (newhash != oldhash) {
        trade.drug.status = "QUARANTINE";
        console.log("myLog: hash different - set as quararantine - oldhash " + oldhash + " newhash " + newhash);
    }


    let assetRegistery = await getAssetRegistry(NS + '.Drug');
    await assetRegistery.update(trade.drug);

    let tradeEvent = factory.newEvent(NS, "TradeEvent");
    tradeEvent.drugSerialNumber = trade.drug.serialNumber;
    tradeEvent.newOwner = factory.newRelationship(NS, 'Actor', trade.newOwner.getIdentifier());
    
    emit(tradeEvent);
}

/**
* Create Drug Transaction - generates hash
* @param {be.howest.bda.task2.createDrug} createdrug
* @transaction
*/

async function createDrug(createdrug) {
    console.log("myLog: creating drug...");
  
     let factory = getFactory();
     let NS = "be.howest.bda.task2";
  
     let temp = createdrug.serialNumber + createdrug.productCode + createdrug.batchNumber + createdrug.manufacturer; 
     let serialhash = Sha256.hash(temp,{});
     console.log("myLog: serialHash :" + serialhash);
     createdrug.hash = serialhash;
     createdrug.status = "MANUFACTURED";
  
     let newdrug = factory.newResource(NS, 'Drug', createdrug.serialNumber);
     newdrug.serialNumber = createdrug.serialNumber;
     newdrug.productCode = createdrug.productCode;
     newdrug.batchNumber = createdrug.batchNumber;
     newdrug.hash = serialhash;
     newdrug.status = "MANUFACTURED";

    //  set owner
    let participantRegistery = await getParticipantRegistry(createdrug.owner.getFullyQualifiedType());
    newdrug.owner = factory.newRelationship(createdrug.owner.getNamespace(),createdrug.owner.getType(), createdrug.owner.getIdentifier());
    let drugOwner = await participantRegistery.get(createdrug.owner.getIdentifier());
    console.log("myLog: drugOwner " + drugOwner);

    // set manufacturer
    let participantRegisteryManu = await getParticipantRegistry(createdrug.manufacturer.getFullyQualifiedType());
    newdrug.manufacturer = factory.newRelationship(createdrug.manufacturer.getNamespace(),createdrug.manufacturer.getType(), createdrug.manufacturer.getIdentifier());
    let drugmanufacturer = await participantRegisteryManu.get(createdrug.manufacturer.getIdentifier());
    console.log("myLog. drugManufacturer " + drugmanufacturer);


     let assetRegistery = await getAssetRegistry(NS + '.Drug');
     await assetRegistery.add(newdrug);
  
     let createDrugEvent = factory.newEvent(NS, "createDrugEvent");
     createDrugEvent.serialhash = createdrug.hash;
       
     emit(createDrugEvent);
  
  }

   
    