//
//  ExerciseRepositoryTests.swift
//  AristaTests
//
//  Created by Pascal Jesenberger on 18/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciseRepositoryTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for exercise in objects {
            context.delete(exercise)
        }
        
        try! context.save()
    }
    
    private func emptyUsers(context: NSManagedObjectContext) {
        let fetchRequest = User.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for user in objects {
            context.delete(user)
        }
        
        try! context.save()
    }
    
    private func addExercise(context: NSManagedObjectContext, category: String, duration: Int, intensity: Int, startDate: Date, userFirstName: String, userLastName: String) {
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        try! context.save()
        
        let newExercise = Exercise(context: context)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = newUser
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String) {
        let newUser = User(context: context)
        newUser.firstName = firstName
        newUser.lastName = lastName
        try! context.save()
    }
    
    func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.isEmpty == true)
    }
    
    func test_WhenAddingOneExerciseInDatabase_GetExercise_ReturnAListContainingTheExercise() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        addExercise(context: persistenceController.container.viewContext,
                   category: "Football",
                   duration: 10,
                   intensity: 5,
                   startDate: date,
                   userFirstName: "Eric",
                   userLastName: "Marcus")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.isEmpty == false)
        XCTAssert(exercises.first?.category == "Football")
        XCTAssert(exercises.first?.duration == 10)
        XCTAssert(exercises.first?.intensity == 5)
        XCTAssert(exercises.first?.startDate == date)
    }
    
    func test_WhenAddingMultipleExerciseInDatabase_GetExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        addExercise(context: persistenceController.container.viewContext,
                   category: "Football",
                   duration: 10,
                   intensity: 5,
                   startDate: date1,
                   userFirstName: "Erica",
                   userLastName: "Marcusi")
        
        addExercise(context: persistenceController.container.viewContext,
                   category: "Running",
                   duration: 120,
                   intensity: 1,
                   startDate: date3,
                   userFirstName: "Erice",
                   userLastName: "Marceau")
        
        addExercise(context: persistenceController.container.viewContext,
                   category: "Fitness",
                   duration: 30,
                   intensity: 5,
                   startDate: date2,
                   userFirstName: "Frédericd",
                   userLastName: "Marcus")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.count == 3)
        XCTAssert(exercises[0].category == "Football")
        XCTAssert(exercises[1].category == "Fitness")
        XCTAssert(exercises[2].category == "Running")
    }
    
    // Tests for addExercise
    
    func test_WhenAddingNewExercise_AddExercise_ShouldAddExerciseToDB() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        emptyUsers(context: persistenceController.container.viewContext)
        
        // Add user first since addExercise needs a user
        addUser(context: persistenceController.container.viewContext, firstName: "Test", lastName: "User")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let startDate = Date()
        
        try! data.addExercise(category: "Swimming", duration: 45, intensity: 3, startDate: startDate)
        
        // Get exercises to verify
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.count == 1)
        XCTAssert(exercises.first?.category == "Swimming")
        XCTAssert(exercises.first?.duration == 45)
        XCTAssert(exercises.first?.intensity == 3)
        XCTAssert(exercises.first?.startDate == startDate)
    }
    
    func test_WhenAddingMultipleExercises_AddExercise_ShouldAddAllExercisesToDB() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        emptyUsers(context: persistenceController.container.viewContext)
        
        // Add user first since addExercise needs a user
        addUser(context: persistenceController.container.viewContext, firstName: "Test", lastName: "User")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let now = Date()
        
        try! data.addExercise(category: "Swimming", duration: 45, intensity: 3, startDate: now)
        try! data.addExercise(category: "Cycling", duration: 60, intensity: 4, startDate: Date(timeInterval: 60*60, since: now))
        try! data.addExercise(category: "Yoga", duration: 30, intensity: 2, startDate: Date(timeInterval: 2*60*60, since: now))
        
        // Get exercises to verify
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.count == 3)
        
        // Exercises should be ordered by startDate (most recent first)
        XCTAssert(exercises[0].category == "Yoga")
        XCTAssert(exercises[1].category == "Cycling")
        XCTAssert(exercises[2].category == "Swimming")
    }
    
    func test_WhenNoUserInDatabase_AddExercise_ShouldThrowError() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        emptyUsers(context: persistenceController.container.viewContext)
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        
        XCTAssertThrowsError(try data.addExercise(category: "Swimming", duration: 45, intensity: 3, startDate: Date())) { error in
            XCTAssertNotNil(error)
        }
    }
    
    // Tests for deleteExercise
    
    func test_WhenDeletingExercise_DeleteExercise_ShouldRemoveExerciseFromDB() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        addExercise(context: persistenceController.container.viewContext,
                   category: "Football",
                   duration: 10,
                   intensity: 5,
                   startDate: date,
                   userFirstName: "Eric",
                   userLastName: "Marcus")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.count == 1)
        
        // Delete the exercise
        try! data.deleteExercise(exercises[0])
        
        // Verify it was deleted
        let exercisesAfterDelete = try! data.getExercise()
        XCTAssert(exercisesAfterDelete.isEmpty)
    }
    
    func test_WhenDeletingOneOfMultipleExercises_DeleteExercise_ShouldOnlyRemoveSpecifiedExercise() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        
        addExercise(context: persistenceController.container.viewContext,
                   category: "Football",
                   duration: 10,
                   intensity: 5,
                   startDate: date1,
                   userFirstName: "Eric",
                   userLastName: "Marcus")
        
        addExercise(context: persistenceController.container.viewContext,
                   category: "Running",
                   duration: 120,
                   intensity: 1,
                   startDate: date2,
                   userFirstName: "Erica",
                   userLastName: "Marcusi")
        
        let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
        let exercises = try! data.getExercise()
        
        XCTAssert(exercises.count == 2)
        
        // Delete the first exercise (Football)
        try! data.deleteExercise(exercises[0])
        
        // Verify only the Football exercise was deleted
        let exercisesAfterDelete = try! data.getExercise()
        XCTAssert(exercisesAfterDelete.count == 1)
        XCTAssert(exercisesAfterDelete[0].category == "Running")
    }
}
