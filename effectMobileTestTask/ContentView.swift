import SwiftUI
import CoreData

struct ContentView: View {

    @StateObject private var viewModel = TaskListViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()

    @FocusState private var isSearchFocused: Bool

    @State private var didSave = false
    @State private var isRecording = false
    @State private var searchText: String = ""
    @State private var isNavigatingToNewTask = false
    @State private var selectedTask: TaskEntity? = nil

    var body: some View {
        NavigationView {
            content
        }
        .onAppear {
            Task {
                await viewModel.loadTasksIfNeeded()
            }
        }
        .onChange(of: didSave) { newValue in
            if newValue {
                Task {
                    await viewModel.loadTasksIfNeeded()
                    didSave = false
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            contentState
            NavigationLink(
                destination: TaskDetailView(existingTask: selectedTask, didSave: $didSave),
                isActive: $isNavigatingToNewTask
            ) {
                EmptyView()
            }
            .background(Color(.systemGray6))
            .ignoresSafeArea(.all)
            taskFooter
        }
        .onChange(of: speechRecognizer.transcribedText) { newValue in
            searchText = newValue
        }
    }

    private var header: some View {
        Text("Задачи")
            .font(.largeTitle).bold()
            .foregroundColor(.primary)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var contentState: some View {
        if viewModel.isLoading {
            ProgressView("Загрузка задач...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            Text("Ошибка: \(error)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            searchBar
            taskList
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Поиск", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)
                .tint(.yellow)
                .focused($isSearchFocused)

            Button(action: {
                if isRecording {
                    speechRecognizer.stopRecording()
                    isRecording = false
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        isSearchFocused = true
                    }
                    speechRecognizer.startRecording()
                    isRecording = true
                }
            }) {
                Image(systemName: isRecording ? "mic.circle.fill" : "mic.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var taskList: some View {
        let filteredItems = viewModel.items.filter {
            searchText.isEmpty ? true :
            ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
            ($0.desc?.lowercased().contains(searchText.lowercased()) ?? false)
        }

        return ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredItems, id: \.objectID) { (task: TaskEntity) in
                    NavigationLink(
                        destination: TaskDetailView(existingTask: task, didSave: $didSave)
                    ) {
                        UIViewRowStyle(task: task)
                            .padding(.horizontal, 20)
                    }
                    .contextMenu {
                        Button {
                            selectedTask = task
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }

                        Button {
                            share(task: task)
                        } label: {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }

                        Button(role: .destructive) {
                            Task {
                                await viewModel.delete(task: task)
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .id(UUID())
    }

    private var taskFooter: some View {
        ZStack {
            HStack {
                Text("\(viewModel.items.count) задач")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            HStack {
                Spacer()
                Button(action: {
                    selectedTask = nil
                    isNavigatingToNewTask = true
                }) {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.yellow)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .ignoresSafeArea(.all)
    }

    private func share(task: TaskEntity) {
        var message = task.title ?? "Задача"
        if let desc = task.desc, !desc.isEmpty {
            message += "\n\nОписание: \(desc)"
        }

        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return ContentView()
        .environment(\.managedObjectContext, context)
}
