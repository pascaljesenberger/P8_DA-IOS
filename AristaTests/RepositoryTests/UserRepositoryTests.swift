//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserRepositoryTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = User.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for user in objects {
            context.delete(user)
        }
        
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String) {
        let newUser = User(context: context)
        newUser.firstName = firstName
        newUser.lastName = lastName
        try! context.save()
    }
    
    func test_WhenNoUserIsInDatabase_GetUser_ReturnNil() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let data = UserRepository(viewContext: persistenceController.container.viewContext)
        let user = try! data.getUser()
        
        XCTAssertNil(user)
    }
    
    func test_WhenOneUserIsInDatabase_GetUser_ReturnTheUser() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        addUser(context: persistenceController.container.viewContext, firstName: "John", lastName: "Doe")
        
        let data = UserRepository(viewContext: persistenceController.container.viewContext)
        let user = try! data.getUser()
        
        XCTAssertNotNil(user)
        XCTAssert(user?.firstName == "John")
        XCTAssert(user?.lastName == "Doe")
    }
    
    func test_WhenMultipleUsersAreInDatabase_GetUser_ReturnTheFirstOneOnly() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        addUser(context: persistenceController.container.viewContext, firstName: "John", lastName: "Doe")
        addUser(context: persistenceController.container.viewContext, firstName: "Jane", lastName: "Smith")
        addUser(context: persistenceController.container.viewContext, firstName: "Alice", lastName: "Johnson")
        
        let data = UserRepository(viewContext: persistenceController.container.viewContext)
        let user = try! data.getUser()
        
        XCTAssertNotNil(user)
        
        // We should only get one user because fetchLimit is set to 1
        // But since the fetchRequest has no sortDescriptors, we can't guarantee which user we get
        // We just check that we got one of the expected users
        XCTAssert(user?.firstName == "John" || user?.firstName == "Jane" || user?.firstName == "Alice")
        
        // Count the number of users we can fetch without limit
        let request = User.fetchRequest()
        let allUsers = try! persistenceController.container.viewContext.fetch(request)
        XCTAssert(allUsers.count == 3)
    }
}
