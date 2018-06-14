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

    let oldhash = trade.drug.hash;

    let serialhashtmp = Sha256.hash(trade.drug.serialNumber,{});
    let serialhash = serialhashtmp.substring(0,6);
    let procodehashtmp = Sha256.hash(trade.drug.productCode,{});
    let procodehash = procodehashtmp.substring(0,6);
    let batchhashtmp = Sha256.hash(trade.drug.batchNumber,{});
    let batchhash = batchhashtmp.substring(0,6);
    let manuhashtmp = Sha256.hash(trade.drug.manufacturer,{});
    let manuhash = manuhashtmp.substring(0,6);
    let newhash = serialhash + procodehash + batchhash + manuhash;



    if (newhash != oldhash) {
        trade.drug.status = "QUARANTINE";
        console.log("myLog: hash different - set as quararantine - oldhash " + oldhash + " newhash " + newhash);
        let hashtext = "QUARAN"
        if (oldhash.substring(0,6) != serialhash) {
            hashtext = hashtext + "SERIALVALS";
            console.log("myLog: FRAUDE ALERT - SERIAL NUMBER ");        
        }
        if (oldhash.substring(6,12) != procodehash) {
            hashtext = hashtext + "PRODUCTCODEVALS";
            console.log("myLog: FRAUDE ALERT - PRODUCT CODE ");
        }
        if (oldhash.substring(12,18) != batchhash) {
            hashtext = hashtext +  "BATCHVALS";
            console.log("myLog: FRAUDE ALERT - BATCH NUMBER ");
        }
        if (oldhash.substring(18,24) != manuhash) {
            hashtext = hashtext +  "MANUVALS";
            console.log("myLog: FRAUDE ALERT - MANUFACTURER ");
        }
        trade.drug.hash = hashtext;
    
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
  
    let serialhashtmp = Sha256.hash(createdrug.serialNumber,{});
    let serialhash = serialhashtmp.substring(0,6);
    let procodehashtmp = Sha256.hash(createdrug.productCode,{});
    let procodehash = procodehashtmp.substring(0,6);
    let batchhashtmp = Sha256.hash(createdrug.batchNumber,{});
    let batchhash = batchhashtmp.substring(0,6);
    let manuhashtmp = Sha256.hash(createdrug.manufacturer,{});
    let manuhash = manuhashtmp.substring(0,6);
    let drughash = serialhash + procodehash + batchhash + manuhash;

    let newdrug = factory.newResource(NS, 'Drug', createdrug.serialNumber);
     newdrug.serialNumber = createdrug.serialNumber;
     newdrug.productCode = createdrug.productCode;
     newdrug.batchNumber = createdrug.batchNumber;
     newdrug.hash = drughash;
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

   
    