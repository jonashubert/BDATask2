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
    trade.commodity.owner = factory.newRelationship(NS, 'Trader', trade.newOwner.getIdentifier());
    let assetRegistery = await getAssetRegistry(NS, '.Commodity');

    await assetRegistrty.update(trade.commodity);
    let tradeEvent = factory.newEvent(NS, "TradeEvent");
    tradeEvent.drugSerialNumber = trade.commodity.serialNumber;
    tradeEvent.newOwner = trade.newOwner.getIdentifier();
    emit(tradeEvent);
}

/**
 * Sample transaction
 * @param {be.howest.bda.task2.verifyOrigin} verify
 * @transaction
 */
async function verifyOrigin(verify) {
    console.log("verifing drug...");

    let factory = getFactory();
    let NS = "be.howest.bda.task2";
    console.log("oldOwner: " + verify.drug.owner.firstName + " " + verify.drug.owner.lastName + " : " + verify.drug.owner.role);
    let ownerRole = verify.drug.owner.role;
    verify.drug.owner = factory.newRelationship(NS, 'Trader', verify.newOwner.getIdentifier());
        
    let drugState = verify.drug.drugState;
    let newOwnerRole = verify.drug.owner.role;

    if (ownerRole == "MANUFACTURER" && drugState== "MANUFACTURED" && newOwnerRole == "DISTRIBUTOR") {
        verify.drug.drugState = "DISTRIBUTED";
    }
    else if (ownerRole == "DISTRIBUTOR" && drugState== "DISTRIBUTING" && newOwnerRole == "PHARMACIST") {
        verify.drug.drugState = "LOCAL_STOCK";
    }
    else if (ownerRole == "PHARMACIST" && drugState== "LOCAL_STOCK" && newOwnerRole == "PATIENT") {
        verify.drug.drugState = "SOLD";
    }
    else {
        verify.drug.drugState = "QUARANTINE";
        const drugs = await query('selectAllDrugsBySerial', {'serialNumber': verify.drug.serialNumber});
        if (drugs.length >= 1) {
            const factory = getFactory();
            const drugsToQuarantaine = drugs.filter(function (drug) {
                return drugs.drugState  != "QUARANTINE";
            });
            for (let x = 0; x < drugsToQuarantaine.length; x++) {
                drugsToQuarantaine[x].drugState = 'QUARANTINE';
                const quarantineDrugEvent = factory.newEvent(NS, 'QuarantineDrugEvent');
                quarantineDrugEvent.drug = drugsToQuarantaine[x];
                emit (quarantineDrugEvent);
            }
            await assetRegistery.updateAll(drugsToQuarantaine);
        }
    }

    let assetRegistery = await getAssetRegistry(NS, '.drug');
    await assetRegistrty.update(verify.drug);
    let tradeEvent = factory.newEvent(NS, "TradeEvent");
    tradeEvent.drugSerialNumber = verify.drug.serialNumber;
    tradeEvent.newOwner = verify.newOwner.getIdentifier();
    emit(tradeEvent);
}

