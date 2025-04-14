//
//  UIViewRowStyle.swift
//  effectMobileTestTask
//
//  Created by Роман on 08.04.2025.
//

import SwiftUI
import Foundation

struct UIViewRowStyle: View {
    
    let task: TaskEntity
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text(task.title ?? "Без названия")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let desc = task.desc {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if let createdAt = task.createdAt {
                        Text(ItemDateFormatter.shared.string(from: createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
                
            }
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.4))
        }
    }
}


final class ItemDateFormatter : DateFormatter, @unchecked Sendable{
    static let shared = ItemDateFormatter()
    
    override init() {
        super.init()
        dateFormat = "dd/MM/yyyy"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = TaskEntity(context: context)
    task.title = "Пример задачи"
    task.desc = "Описание задачи"
    task.isCompleted = !false
    task.createdAt = Date()
    
    return UIViewRowStyle(task: task)
}
