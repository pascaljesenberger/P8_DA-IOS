//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class UserDataViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellables.removeAll()
    }
    
    func test_WhenNoUserIsInDatabase_FetchUserData_SetsErrorMessageAndShowsAlert() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let expectation = XCTestExpectation(description: "show error alert when no user found")
        
        let viewModel = UserDataViewModel(context: persistenceController.container.viewContext)
        
        // Check that error is shown
        viewModel.$showErrorAlert
            .dropFirst() // Skip initial false value
            .sink { showErrorAlert in
                XCTAssertTrue(showErrorAlert)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
        
        // Also verify that firstName and lastName are empty
        XCTAssertEqual(viewModel.firstName, "")
        XCTAssertEqual(viewModel.lastName, "")
    }
    
    func test_WhenUserExistsInDatabase_FetchUserData_LoadsUserData() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        // Add a user
        addUser(context: persistenceController.container.viewContext,
               firstName: "Jean",
               lastName: "Dupont")
        
        // Initialize view model
        let viewModel = UserDataViewModel(context: persistenceController.container.viewContext)
        
        // Check that the user data was loaded correctly
        XCTAssertEqual(viewModel.firstName, "Jean")
        XCTAssertEqual(viewModel.lastName, "Dupont")
        XCTAssertFalse(viewModel.showErrorAlert)
    }
    
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
}
