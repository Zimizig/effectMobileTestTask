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
    
    @Binding var didSave: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var titleText: String
    @State private var descText: String
    @State private var isCompleted: Bool
    
    let createdAt: Date
    
    init(existingTask: TaskEntity? = nil, didSave: Binding<Bool>) {
        self.existingTask = existingTask
        self.createdAt = existingTask?.createdAt ?? Date()
        self._didSave = didSave
        
        _titleText = State(initialValue: existingTask?.title ?? "")
        _descText = State(initialValue: existingTask?.desc ?? "")
        _isCompleted = State(initialValue: existingTask?.isCompleted ?? false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
           TextField("Заголовок", text: $titleText)
                .font(Font.system(size: 34, weight: .bold))
                .accentColor(.yellow)
            
            Text(ItemDateFormatter.shared.string(from: createdAt))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                if descText.isEmpty {
                    Text("Описание")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.leading, 0)
                        .padding(.top, 12)
                        .zIndex(1)
                }
                TextEditor(text: $descText)
                    .frame(height: 200)
                    .padding(.leading, -4)
                    .padding(.top, 4)
                    .background(Color.clear)
                    .accentColor(.yellow)
                    .font(.body)
            }

            
            Spacer()
            
            Button ("Сохранить") {
                saveTask()
            }
            .buttonStyle(YellowPrimaryButtonStyle())
            .padding(.top, 20)
            .padding(.bottom, 25)
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
    
    private func saveTask() {
        let task = existingTask ?? TaskEntity(context: viewContext)
        task.title = titleText
        task.desc = descText
        task.isCompleted = isCompleted
        task.createdAt = createdAt
        
        do {
            try viewContext.save()
            didSave = true
            dismiss()
        } catch {
            print("❌ Ошибка сохранения: \(error)")
        }
    }
    
}

#Preview {
    // Создаём тестовый контекст для предпросмотра
    let context = PersistenceController.preview.container.viewContext
    
    NavigationView {
        TaskDetailView(existingTask: nil, didSave: .constant(false))
            .environment(\.managedObjectContext, context)
    }
}
