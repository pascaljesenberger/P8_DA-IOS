//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class SleepRepositoryTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for sleep in objects {
            context.delete(sleep)
        }
        
        try! context.save()
    }
    
    private func addSleepSession(context: NSManagedObjectContext, startDate: Date, endDate: Date, quality: Int, userFirstName: String, userLastName: String) {
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        try! context.save()
        
        let newSleep = Sleep(context: context)
        newSleep.startDate = startDate
        newSleep.quality = Int64(quality)
        newSleep.user = newUser
        try! context.save()
    }
    
    func test_WhenNoSleepSessionIsInDatabase_GetSleepSessions_ReturnEmptyList() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let data = SleepRepository(viewContext: persistenceController.container.viewContext)
        let sleepSessions = try! data.getSleepSessions()
        
        XCTAssert(sleepSessions.isEmpty == true)
    }
    
    func test_WhenAddingOneSleepSessionInDatabase_GetSleepSessions_ReturnAListContainingTheSleepSession() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let startDate = Date()
        let endDate = Date(timeInterval: 8*60*60, since: startDate)
        addSleepSession(context: persistenceController.container.viewContext,
                        startDate: startDate,
                        endDate: endDate,
                        quality: 4,
                        userFirstName: "John",
                        userLastName: "Doe")
        
        let data = SleepRepository(viewContext: persistenceController.container.viewContext)
        let sleepSessions = try! data.getSleepSessions()
        
        XCTAssert(sleepSessions.isEmpty == false)
        XCTAssert(sleepSessions.first?.startDate == startDate)
        XCTAssert(sleepSessions.first?.quality == 4)
    }
    
    func test_WhenAddingMultipleSleepSessionsInDatabase_GetSleepSessions_ReturnAListContainingTheSleepSessionsInTheRightOrder() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        addSleepSession(context: persistenceController.container.viewContext,
                        startDate: date1,
                        endDate: Date(timeInterval: 8*60*60, since: date1),
                        quality: 5,
                        userFirstName: "John",
                        userLastName: "Doe")
        
        addSleepSession(context: persistenceController.container.viewContext,
                        startDate: date3,
                        endDate: Date(timeInterval: 6*60*60, since: date3),
                        quality: 3,
                        userFirstName: "Jane",
                        userLastName: "Smith")
        
        addSleepSession(context: persistenceController.container.viewContext,
                        startDate: date2,
                        endDate: Date(timeInterval: 7*60*60, since: date2),
                        quality: 4,
                        userFirstName: "Alice",
                        userLastName: "Johnson")
        
        let data = SleepRepository(viewContext: persistenceController.container.viewContext)
        let sleepSessions = try! data.getSleepSessions()
        
        XCTAssert(sleepSessions.count == 3)
        // Check ordering - most recent first
        XCTAssert(sleepSessions[0].startDate == date1)
        XCTAssert(sleepSessions[1].startDate == date2)
        XCTAssert(sleepSessions[2].startDate == date3)
    }
}
