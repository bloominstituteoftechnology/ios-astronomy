////
////  PhotoController.swift
////  Astronomy
////
////  Created by macbook on 10/31/19.
////  Copyright © 2019 Lambda School. All rights reserved.
////
//
//import Foundation
//
//
//func loadFromPersistentStore(completion: @escaping (Error?) -> Void) {
//    
//    let bgQueue = DispatchQueue(label: "studentQueue")
//    
//    // Wait two seconds before calling this closure
//    bgQueue.asyncAfter(deadline: .now() + 2) {
//        
//        let fileManager = FileManager.default
//        
//        // Make sure the students.json file exists
//        guard let url = self.persistentFileURL,
//            fileManager.fileExists(atPath: url.path) else {
//                completion([])
//                return
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            
//            let decoder = JSONDecoder()
//            // What format is this JSON in? How do you want to decode it?
//            let students = try decoder.decode([Student].self, from: data)
//            
//            completion(students)
//        } catch {
//            print("Error loading students from JSON: \(error)")
//            completion([])
//        }
//    }
//}
