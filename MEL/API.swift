//
//  API.swift
//  MEL
//
//  Created by Hen Levy on 08/08/2018.
//  Copyright © 2018 Hen Levy. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class API {
    static let shared = API()
    var dbRef = Database.database().reference()
    
//    func searchRoom(_ text: String, success: @escaping ([Room])->(), failure: @escaping ()->()) {
//        let words = text.components(separatedBy: " ")
//        for word in words {
//            searchRoom(word, success: success, failure: failure)
//        }
//    }
    
    func searchRoom(_ text: String, success: @escaping ([Room])->(), failure: @escaping ()->()) {
        
        dbRef.child("rooms").queryOrdered(byChild: "name").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observeSingleEvent(of: .value) { snapshot in
        
            if snapshot.exists() {
                var rooms = [Room]()
                for r in snapshot.children.allObjects as! [DataSnapshot] {
                    if let item = r.value as? [String: Any] {
                        let room = self.createRoom(from: item)
                        rooms.append(room)
                    }
                }
                success(rooms)
            } else {
                failure()
            }
        }
    }
    
    func getUserRoomsList(success: (([Room])->())? = nil, failure: (()->())? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        dbRef.child("users/\(uid)/rooms").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var rooms = [Room]()
                for r in snapshot.children.allObjects as! [DataSnapshot] {
                    if let item = r.value as? [String: Any] {
                        let room = self.createRoom(from: item)
                        rooms.append(room)
                    }
                }
                success?(rooms)
            } else {
                failure?()
            }
        }
    }

    func checkIfRoomAlreadyExists(roomName: String, roomAddress: String, completion: @escaping (Bool) -> ()) {
        dbRef.child("rooms").queryOrdered(byChild: "name").queryEqual(toValue: roomName).observeSingleEvent(of: .value) { snapshot in
            
            if !snapshot.exists() {
                completion(false)
            } else {
                for r in snapshot.children.allObjects as! [DataSnapshot] {
                    if let item = r.value as? [String: Any], let address = item["address"] as? String, address == roomAddress {
                        completion(true)
                        return
                    }
                }
                completion(false)
            }
            
            
        }
    }
    
    func checkIfRoomExistsInUserRoomsList(roomName: String, completion: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        dbRef.child("users/\(uid)/rooms").queryOrdered(byChild: "id").queryEqual(toValue: roomName).observeSingleEvent(of: .value) { snapshot in
            
            completion(snapshot.exists())
        }
    }
    
    func addNewRoom(_ room: Room, success: (()->())? = nil, failure: (()->())? = nil) {
        let roomData = createRoomData(from: room)
        let roomId = roomData["id"] as! String
        
        // add new room to the global rooms list
        dbRef.child("rooms/\(roomId)").setValue(roomData) { (error, dbRef) in
            if let error = error {
                debugPrint(error.localizedDescription)
                failure?()
                return
            }
            debugPrint("room successfully added to rooms list")
            success?()
        }
    }
    
    func addRoomToUserRoomsList(_ room: Room, success: (()->())? = nil, failure: (()->())? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let roomData = createRoomData(from: room)
        let roomId = roomData["id"] as! String
        
        // add new room to user's rooms list
        dbRef.child("users/\(uid)/rooms/\(roomId)").setValue(roomData) { (error, dbRef) in
            if let error = error {
                debugPrint(error.localizedDescription)
                failure?()
                return
            }
            debugPrint("room successfully added to user's rooms list")
            success?()
        }
    }
    
    func createRoom(from roomData: [String: Any]) -> Room {
        let room = Room()
        room.id = roomData["id"] as? String
        room.name = roomData["name"] as? String
        room.address = roomData["address"] as? String
        room.rating = roomData["rating"] as? Double
        return room
    }
    
    func createRoomData(from room: Room) -> [String: Any] {
        var roomData = [String: Any]()
        roomData["id"] = room.id ?? ""
        roomData["name"] = room.name ?? ""
        roomData["address"] = room.address ?? ""
        roomData["rating"] = room.rating ?? 0
        return roomData
    }
}

enum APIError {
    case roomAlreadyExist
}
