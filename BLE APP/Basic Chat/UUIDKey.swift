//
//  UUIDKey.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/3/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//

import CoreBluetooth
//Uart Service uuid


let kBLEService_UUID = "1811"
let kBLE_Characteristic_uuid_Tx = "12345678-1234-5678-1234-56789abcdef5"
let kBLE_Characteristic_uuid_Rx = "2a46"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
