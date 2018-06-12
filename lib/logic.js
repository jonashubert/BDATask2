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
 * Sample transaction
 * @param {be.howest.bda.task2.Trade} trade
 * @transaction
 */
async function tradeDrug(trade) {
    console.log("trading drug...");

    let factory = getFactory();
    let NS = "be.howest.bda.task2";
    console.log("oldOwner: " + trade.commodity.owner.firstName + " " + trade.commodity.owner.firstName + " : " + trade.commodity.owner.role);
    trade.commodity.owner = factory.newRelationship(NS, 'Actor', trade.newOwner.getIdentifier());
    let assetRegistery = await getAssetRegistry(NS, '.Commodity');

    await assetRegistrty.update(trade.commodity);
    let tradeEvent = factory.newEvent(NS, "TradeEvent");
    tradeEvent.drugSerialNumber = trade.commodity.serialNumber;
    tradeEvent.newOwner = trade.newOwner.getIdentifier();
    emit(tradeEvent);
}

/**
 * Sample transaction
 * @param {be.howest.bda.task2.VerifyOrigin} verify
 * @transaction
 */
async function verifyOrigin(verify) {
    console.log("myLog: verifing drug...");
	console.log("myLog: hashing..." + Sha256.hash("mmmmm",{})); 
    let factory = getFactory();
    let NS = "be.howest.bda.task2";
    console.log("myLog: oldOwner: " + verify.drug.owner.firstName + " " + verify.drug.owner.lastName + " : " + verify.drug.owner.role);
    let ownerRole = verify.drug.owner.role;
    let drugState = verify.drug.status;
    console.log("myLog: newOwner: "+  verify.newOwner.getIdentifier());
    let participantRegistery = await getParticipantRegistry(verify.newOwner.getFullyQualifiedType());
    console.log("myLog: FQT: " + verify.newOwner.getFullyQualifiedType());
    console.log("myLog: NS: " + verify.newOwner.getNamespace());
    console.log("myLog: ID: " + verify.newOwner.getIdentifier());
    verify.drug.owner = factory.newRelationship(verify.newOwner.getNamespace(),verify.newOwner.getType(), verify.newOwner.getIdentifier());
    let newOwner = await participantRegistery.get(verify.newOwner.getIdentifier());

    

    console.log("myLog: newOwner: " + newOwner);
    let newOwnerRole = newOwner.role;

    console.log("myLog: ownerRole: " + ownerRole + "; drugState: " + drugState + "; newOwnerRole: " + newOwnerRole);
    

    if (ownerRole == "MANUFACTURER" && drugState== "MANUFACTURED" && newOwnerRole == "DISTRIBUTOR") {
        verify.drug.status = "DISTRIBUTING";
        console.log("myLog: Status set as DISTRIBUTED");
    }
    else if (ownerRole == "DISTRIBUTOR" && drugState== "DISTRIBUTING" && newOwnerRole == "PHARMACIST") {
        verify.drug.status = "LOCAL_STOCK";
        console.log("myLog: Status set as LOCAL STOCK");
    }
    else if (ownerRole == "PHARMACIST" && drugState== "LOCAL_STOCK" && newOwnerRole == "PATIENT") {
        verify.drug.status = "SOLD";
        console.log("myLog: Status set as SOLD");
    }
    else {
        verify.drug.status = "QUARANTINE";
        console.log("myLog: Status set as QUARANTINE");
        const drugs = await query('selectAllDrugsBySerial', {'serial': verify.drug.serialNumber});
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

    let assetRegistery = await getAssetRegistry(NS + '.Drug');
    await assetRegistery.update(verify.drug);

    let tradeEvent = factory.newEvent(NS, "TradeEvent");
    tradeEvent.drugSerialNumber = verify.drug.serialNumber;
    tradeEvent.newOwner = factory.newRelationship(NS, 'Actor', verify.newOwner.getIdentifier());
    
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
     //console.log("myLog: Serial Number: " + createdrug.drug.serialNumber + " Product code: " + createdrug.drug.productCode + " batch number: " + createdrug.drug.batchNumber + " Manufacturer: " + createdrug.drug.Manufacturer.actorId);
  
     let serialhash = Sha256.hash(createdrug.serialNumber,{});
     console.log("myLog: serialHash " + serialhash);
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

   
    