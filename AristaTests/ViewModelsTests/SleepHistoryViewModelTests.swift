//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class SleepHistoryViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellables.removeAll()
    }
    
    func test_WhenNoSleepSessionIsInDatabase_FetchSleepSessions_ReturnEmptyList() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
        let expectation = XCTestExpectation(description: "fetch empty list of sleep sessions")
        
        viewModel.$sleepSessions
            .sink { sleepSessions in
                XCTAssert(sleepSessions.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenAddingOneSleepSessionInDatabase_FetchSleepSessions_ReturnAListContainingTheSleepSession() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        let date = Date()
        
        addSleepSession(context: persistenceController.container.viewContext,
                      duration: 480,
                      quality: 8,
                      startDate: date,
                      userFirstName: "Eric",
                      userLastName: "Marcus")
        
        let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
        let expectation = XCTestExpectation(description: "fetch list with one sleep session")
        
        viewModel.$sleepSessions
            .sink { sleepSessions in
                XCTAssert(sleepSessions.isEmpty == false)
                XCTAssert(sleepSessions.first?.duration == 480)
                XCTAssert(sleepSessions.first?.quality == 8)
                XCTAssert(sleepSessions.first?.startDate == date)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenAddingMultipleSleepSessionsInDatabase_FetchSleepSessions_ReturnAListContainingTheSleepSessionsInTheRightOrder() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        addSleepSession(context: persistenceController.container.viewContext,
                      duration: 480,
                      quality: 8,
                      startDate: date1,
                      userFirstName: "Eric",
                      userLastName: "Marcus")
        
        addSleepSession(context: persistenceController.container.viewContext,
                      duration: 360,
                      quality: 6,
                      startDate: date3,
                      userFirstName: "Eric",
                      userLastName: "Marcus")
        
        addSleepSession(context: persistenceController.container.viewContext,
                      duration: 420,
                      quality: 7,
                      startDate: date2,
                      userFirstName: "Eric",
                      userLastName: "Marcus")
        
        let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
        let expectation = XCTestExpectation(description: "fetch list with multiple sleep sessions")
        
        viewModel.$sleepSessions
            .sink { sleepSessions in
                XCTAssert(sleepSessions.count == 3)
                XCTAssert(sleepSessions[0].startDate == date1)
                XCTAssert(sleepSessions[1].startDate == date2)
                XCTAssert(sleepSessions[2].startDate == date3)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for sleep in objects {
            context.delete(sleep)
        }
        
        // Also delete users
        let userFetchRequest = User.fetchRequest()
        let users = try! context.fetch(userFetchRequest)
        
        for user in users {
            context.delete(user)
        }
        
        try! context.save()
    }
    
    private func addSleepSession(context: NSManagedObjectContext, duration: Int64, quality: Int64, startDate: Date, userFirstName: String, userLastName: String) {
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        try! context.save()
        
        let newSleep = Sleep(context: context)
        newSleep.duration = duration
        newSleep.quality = quality
        newSleep.startDate = startDate
        newSleep.user = newUser
        try! context.save()
    }
}
