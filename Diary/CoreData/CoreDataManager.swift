//
//  CoreDataManager.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2022/12/27.
//

import Foundation
import CoreData

class CoreDataManager {
    static var shared: CoreDataManager = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var diaryEntity: NSEntityDescription? {
        return  NSEntityDescription.entity(forEntityName: "DiaryEntity", in: context)
    }

    // MARK: - CREATE
    func create(diary: Diary) {
        createDiaryEntity(diary: diary)
        saveContext()
    }

    private func createDiaryEntity(diary: Diary) {
        if let entity = diaryEntity {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            managedObject.setValue(diary.title, forKey: "title")
            managedObject.setValue(diary.body, forKey: "body")
            managedObject.setValue(diary.createdAt, forKey: "createdAt")
            managedObject.setValue(diary.uuid, forKey: "uuid")
            managedObject.setValue(diary.weather?.description, forKey: "weatherDescription")
            managedObject.setValue(diary.weather?.icon, forKey: "weatherIcon")
        }
    }

    private func saveContext() {
        if !context.hasChanges {
            return
        }

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - READ
    func readDiaryEntity() -> [DiaryEntity] {
        return fetchDiaryEntity()
    }

    private func fetchDiaryEntity() -> [DiaryEntity] {
        do {
            let request = DiaryEntity.fetchRequest()
            let results = try context.fetch(request)

            return results
        } catch {
            print(error.localizedDescription)
        }

        return []
    }

    // MARK: - UPDATE
    func update(diary: Diary) {
        let fetchResults = fetchDiaryEntity()
        if fetchResults.contains(where: { $0.uuid == diary.uuid }) {
            for result in fetchResults where result.uuid == diary.uuid {
                result.title = diary.title
                result.body = diary.body
            }
        } else {
            create(diary: diary)
        }

        saveContext()
    }

    // MARK: - DELETE
    func delete(diary: Diary) {
        let fetchResults = fetchDiaryEntity()
        guard let diaryEntity = fetchResults.first(where: { $0.uuid == diary.uuid }) else {
            return
        }

        context.delete(diaryEntity)
        saveContext()
    }
}
