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
