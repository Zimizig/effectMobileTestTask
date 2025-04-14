//
//  TaskDetailView.swift
//  effectMobileTestTask
//
//  Created by Роман on 09.04.2025.
//

import SwiftUI
import CoreData

struct TaskDetailView: View {
    let existingTask: TaskEntity?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var titleText: String
    @State private var descText: String
    @State private var isCompleted: Bool
    
    init(existingTask: TaskEntity? = nil) {
        self.existingTask = existingTask
        _titleText = State(initialValue: existingTask?.title ?? "")
        _descText = State(initialValue: existingTask?.desc ?? "")
        _isCompleted = State(initialValue: existingTask?.isCompleted ?? false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Заголовок задачи")
                .font(.headline)
            
            TextField("Введите заголовок", text: $titleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextEditor(text: $descText)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            if existingTask != nil {
                Text(existingTask?.title ?? "Без названия")
                    .font(.largeTitle)
                    .bold()
                
                if let createdAt = existingTask?.createdAt {
                    Text(ItemDateFormatter.shared.string(from: createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let desc = existingTask?.desc, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("Описание")
                            .font(.caption)
                            .foregroundColor(Color.primary)
                        
                        Text(desc)
                            .font(.body)
                            .foregroundColor(Color.primary)
                    }
                } else {
                    Text("Описание отсутствует")
                        .foregroundColor(Color.primary)
                }
            }
            Spacer()
            Button ("Сохранить") {
                guard !titleText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                
                if let task = existingTask {
                    task.title = titleText
                    task.desc = descText
                    task.isCompleted = isCompleted
                } else {
                    let newTask = TaskEntity(context: viewContext)
                    newTask.title = titleText
                    newTask.desc = descText
                    newTask.isCompleted = isCompleted
                    newTask.createdAt = Date()
                }
                
                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    print("💥 Ошибка при сохранении: \(error.localizedDescription)")
                }
            }
            .buttonStyle(YellowPrimaryButtonStyle())
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        Text("Назад")
                            .font(.body)
                            .bold()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

#Preview {
    // Создаём тестовый контекст для предпросмотра
    let context = PersistenceController.preview.container.viewContext
    let previewTask: TaskEntity = {
        let task = TaskEntity(context: context)
        task.title = "Проверка задачи"
        task.desc = "Это подробное описание задачи"
        task.isCompleted = false
        task.createdAt = Date()
        return task
    }()
    NavigationView {
        TaskDetailView(existingTask: previewTask)
    }
}
