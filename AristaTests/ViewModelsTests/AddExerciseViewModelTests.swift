//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class AddExerciseViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellables.removeAll()
    }
    
    func test_WhenFieldsAreEmpty_AddExercise_ReturnsFalseAndShowsError() {
        let persistenceController = PersistenceController(inMemory: true)
        let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
        
        // Prepare test data with empty values
        viewModel.wheel = ""
        viewModel.duration = 0
        viewModel.intensity = 0
        
        // Call method and verify return value
        let result = viewModel.addExercise()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenCategoryIsEmpty_AddExercise_ReturnsFalseAndShowsError() {
        let persistenceController = PersistenceController(inMemory: true)
        let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
        
        // Prepare test data with empty category
        viewModel.wheel = ""
        viewModel.duration = 30
        viewModel.intensity = 5
        
        // Call method and verify return value
        let result = viewModel.addExercise()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenDurationIsZero_AddExercise_ReturnsFalseAndShowsError() {
        let persistenceController = PersistenceController(inMemory: true)
        let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
        
        // Prepare test data with zero duration
        viewModel.wheel = "Football"
        viewModel.duration = 0
        viewModel.intensity = 5
        
        // Call method and verify return value
        let result = viewModel.addExercise()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenIntensityIsZero_AddExercise_ReturnsFalseAndShowsError() {
        let persistenceController = PersistenceController(inMemory: true)
        let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
        
        // Prepare test data with zero intensity
        viewModel.wheel = "Football"
        viewModel.duration = 30
        viewModel.intensity = 0
        
        // Call method and verify return value
        let result = viewModel.addExercise()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenAllFieldsAreValid_AddExercise_ReturnsTrueAndSavesExercise() throws {
        // Setup
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        
        // Create a user first (required for exercise)
        let user = User(context: context)
        user.firstName = "Test"
        user.lastName = "User"
        try context.save()
        
        let viewModel = AddExerciseViewModel(context: context)
        
        // Prepare test data with valid values
        viewModel.wheel = "Running"
        viewModel.duration = 45
        viewModel.intensity = 7
        viewModel.startTime = Date()
        
        // Call method and verify return value
        let result = viewModel.addExercise()
        XCTAssertTrue(result)
        XCTAssertFalse(viewModel.showErrorAlert)
        
        // Verify that exercise was saved in database
        let fetchRequest = Exercise.fetchRequest()
        let exercises = try context.fetch(fetchRequest)
        
        XCTAssertEqual(exercises.count, 1)
        XCTAssertEqual(exercises.first?.category, "Running")
        XCTAssertEqual(exercises.first?.duration, 45)
        XCTAssertEqual(exercises.first?.intensity, 7)
    }
}
