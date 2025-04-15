//
//  TaskListViewModel.swift
//  effectMobileTestTask
//
//  Created by Роман on 09.04.2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
final class TaskListViewModel: ObservableObject {
    
    private let context = PersistenceController.shared.container.viewContext
    
    @AppStorage(AppStorageKeys.isFirstLaunch) private var isFirstLaunch: Bool = true
    
    @Published var items: [TaskEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadTasksIfNeeded() async {
        isLoading = true
        errorMessage = nil
        print("🟡 loadTasksIfNeeded вызван")
        
        
        if isFirstLaunch {
            print("🟢 Первый запуск — грузим из сети")
            await loadFromNetworkAndSave()
            isFirstLaunch = false
        }
        
        await loadFromCoreData()
        isLoading = false
    }
    
    func loadFromCoreData() async {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: true)]
        
        do {
            let result = try context.fetch(request)
            DispatchQueue.main.async {
                self.items = result
                print("📦 Загружено задач из CoreData: \(result.count)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Ошибка при загрузке: \(error)")
        }
    }
    
    // Добавлено !!!
    func delete(task: TaskEntity) async {
        context.delete(task)
        do {
            try context.save()
            await loadFromCoreData()
        } catch {
            print("Ошибка при удалении задачи: \(error)")
        }
    }
    
    private func loadFromNetworkAndSave() async {
             //print("🌐 Начинаем загрузку из сети...")
            do {
                let result = try await NetworkService.shared.fetchTasks()
                //print("✅ Получено задач из API: \(result.count)")
                for task in result {
                    //print("📝 \(task.todo)")
                    let entity = TaskEntity(context: context)
                    entity.id = UUID()
                    entity.title = task.todo
                    entity.desc = ""
                    entity.isCompleted = task.completed
                    entity.createdAt = Date()
                }
                try context.save()
                //print("✅ Задачи успешно сохранены в Core Data.")
            } catch {
                //print("❌ Ошибка при загрузке или сохранении: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
}
