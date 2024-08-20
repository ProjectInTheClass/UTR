//
//  ContentView.swift
//  UTR_APP
//
//  Created by Neo on 8/8/24.
//
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            if isActive {
                MainPageView()
            } else {
                VStack {
                    Image("UTR")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.2)
                        .padding()
                }
                .onAppear {
                    requestNotificationPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한이 허용되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
}

struct MainPageView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimetableView()
                .tabItem {
                    Image(systemName: "calendar.circle")
                    Text("시간표")
                }
                .tag(0)
            
            ExamAssignmentView()
                .tabItem {
                    Image(systemName: "book.circle")
                    Text("시험 / 과제")
                }
                .tag(1)
            
            Text("오늘 일정")
                .tabItem {
                    Image(systemName: "list.bullet.circle")
                    Text("오늘 일정")
                }
                .tag(2)
            
            Text("알림")
                .tabItem {
                    Image(systemName: "bell.circle")
                    Text("알림")
                }
                .tag(3)
            
            MyPage()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("MY")
                }
                .tag(4)
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct TimetableView: View {
    @State private var showingAddTimetableSelection = false
    @State private var showingTimetableList = false
    @AppStorage("timetableItems") private var timetableItemsData: Data = Data()
    @State private var timetableItems: [TimetableItem] = []
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showingTimetableList = true
                }) {
                    Text("시간표")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.black)
                }
                .sheet(isPresented: $showingTimetableList) {
                    TimetableListView()
                }
                
                Spacer()
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    showingAddTimetableSelection = true
                }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 20)
            
            ZStack {
                HStack {
                    Spacer()
                    TimetableGridView(timetableItems: $timetableItems)
                        .padding(.vertical, 50)
                    Spacer()
                }
                .zIndex(1.0)
                Rectangle()
                    .fill(Color.litegrayColor)
                    
            }
               
        }
        .sheet(isPresented: $showingAddTimetableSelection) {
            AddTimetableView(timetableItems: $timetableItems)
        }
        .onAppear {
            if let decodedItems = try? JSONDecoder().decode([TimetableItem].self, from: timetableItemsData) {
                timetableItems = decodedItems
            }
        }
        .onChange(of: timetableItems) { newValue in
            if let encodedData = try? JSONEncoder().encode(newValue) {
                timetableItemsData = encodedData
            }
        }
    }
}

struct TimetableGridView: View {
    @Binding var timetableItems: [TimetableItem]
    @State private var selectedItem: TimetableItem?

    let days = ["월", "화", "수", "목", "금"]
    let hours = Array(9...20)

    var body: some View {
        GeometryReader { geometry in
            let gridWidth = (geometry.size.width - 70) / CGFloat(days.count)
            let gridHeight = (geometry.size.height - 50) / CGFloat(hours.count)

            VStack(spacing: 0) {
                // 헤더 영역
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 50, height: gridHeight)
                        .background(Color.gray.opacity(0.2))

                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .frame(width: gridWidth, height: gridHeight)
                            .background(Color.gray.opacity(0.2))
                            .border(Color.gray.opacity(0.7)) // 짙은 회색으로 변경
                            .cornerRadius(5) // 곡률 적용
                    }
                }

                // 시간표 영역
                ForEach(hours, id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text("\(hour)")
                            .frame(width: 50, height: gridHeight)
                            .background(Color.gray.opacity(0.2))
                            .border(Color.gray.opacity(0.7)) // 짙은 회색으로 변경
                            .cornerRadius(5) // 곡률 적용

                        ForEach(days.indices, id: \.self) { dayIndex in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .border(Color.gray.opacity(0.7)) // 짙은 회색으로 변경
                                    .frame(width: gridWidth, height: gridHeight)
                                    .cornerRadius(5) // 곡률 적용

                                // 시간표 항목 렌더링
                                ForEach(timetableItems) { item in
                                    let startHour = Calendar.current.component(.hour, from: item.startTime)
                                    let endHour = Calendar.current.component(.hour, from: item.endTime)

                                    if item.dayIndex == dayIndex && (startHour <= hour && hour < endHour) {
                                        VStack {
                                            Text(item.title)
                                                .foregroundColor(.white) // 텍스트 색상 흰색으로 설정
                                                .padding(5) // 텍스트 패딩 추가
                                        }
                                        .frame(width: gridWidth, height: gridHeight * CGFloat(endHour - startHour))
                                        .background(item.color.color)
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            selectedItem = item
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .padding(.horizontal, 10)
        }
        .sheet(item: $selectedItem) { item in
            TimetableDetailView(timetableItem: item, timetableItems: $timetableItems)
        }
        .padding(.bottom, 50)
    }
}
struct TimetableDetailView: View {
    var timetableItem: TimetableItem
    @Binding var timetableItems: [TimetableItem]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text(timetableItem.title)
                    .font(.largeTitle)
                    .padding()
                
                Text("장소: \(timetableItem.location)")
                Text("교수: \(timetableItem.professor)")
                Text("시간: \(timetableItem.startTime.formatted(date: .omitted, time: .shortened)) - \(timetableItem.endTime.formatted(date: .omitted, time: .shortened))")
                
                Spacer()
                
                Button(action: {
                    if let index = timetableItems.firstIndex(where: { $0.id == timetableItem.id }) {
                        timetableItems.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("삭제")
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddTimetableView: View {
    @Binding var timetableItems: [TimetableItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var professor: String = ""
    @State private var color: Color = .blue
    @State private var day: String = "월"
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("강의 정보")) {
                    TextField("수업명", text: $title)
                    TextField("교수명", text: $professor)
                    TextField("장소", text: $location)
                    ColorPicker("색상", selection: $color)
                }
                
                Section(header: Text("시간 설정")) {
                    Picker("요일", selection: $day) {
                        ForEach(["월", "화", "수", "목", "금"], id: \.self) { Text($0) }
                    }
                    DatePicker("시작 시간", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("종료 시간", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Button("저장") {
                        let newItem = TimetableItem(
                            title: title,
                            location: location,
                            professor: professor,
                            color: CodableColor(color: color),
                            day: day,
                            startTime: startTime,
                            endTime: endTime
                        )
                        timetableItems.append(newItem)
                        scheduleNotification(for: newItem)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("수업 추가")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func scheduleNotification(for item: TimetableItem) {
        let content = UNMutableNotificationContent()
        content.title = "곧 시작할 수업: \(item.title)"
        content.body = "\(item.professor) 교수님의 수업이 \(item.location)에서 시작됩니다."
        content.sound = UNNotificationSound.default
        
        // Set the notification trigger to the class start time
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

struct TimetableItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var location: String
    var professor: String
    var color: CodableColor
    var day: String
    var startTime: Date
    var endTime: Date
    
    var dayIndex: Int {
        switch day {
        case "월": return 0
        case "화": return 1
        case "수": return 2
        case "목": return 3
        case "금": return 4
        default: return 0
        }
    }
}

struct CodableColor: Codable, Equatable {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        color = Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let components = color.components()
        try container.encode(components.red, forKey: .red)
        try container.encode(components.green, forKey: .green)
        try container.encode(components.blue, forKey: .blue)
        try container.encode(components.opacity, forKey: .opacity)
    }
}

extension Color {
    static let litegrayColor: Color = .init("litegray")
    
    func components() -> (red: Double, green: Double, blue: Double, opacity: Double) {
        guard let components = self.cgColor?.components else {
            return (red: 0, green: 0, blue: 0, opacity: 1)
        }
        
        let red = Double(components[safe: 0] ?? 0)
        let green = Double(components[safe: 1] ?? 0)
        let blue = Double(components[safe: 2] ?? 0)
        let opacity = Double(components[safe: 3] ?? 1)
        
        return (red, green, blue, opacity)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

struct TimetableListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("시간표")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        // 추가 기능이 필요할 경우 여기에 구현
                    }) {
                        Image(systemName: "plus.square")
                            .foregroundStyle(.black)
                            .font(.title)
                            .padding()
                    }
                }
                
                List {
                    
                    Section(header: Text("1학년 1학기")) {
                        NavigationLink(destination: TimetableView()) {
                            Text("1학년 1학기")
                        }
                    }
                    
                    Section(header: Text("1학년 2학기")) {
                        NavigationLink(destination: TimetableView()) {
                            Text("1학년 2학기")
                        }
                    }
                    
                    Section(header: Text("2학년 1학기")) {
                        NavigationLink(destination: TimetableView()) {
                            Text("2학년 1학기")
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @State private var isNotificationEnabled = true
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일반 설정")) {
                    Toggle("알림", isOn: $isNotificationEnabled)
                    Toggle("다크 모드", isOn: $isDarkModeEnabled)
                }
                
                Section(header: Text("계정")) {
                    NavigationLink(destination: ProfileView()) {
                        Text("프로필")
                    }
                    Button(action: {
                        // 로그아웃 액션을 여기에 추가
                        logout()
                    }) {
                        Text("로그아웃")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("설정")
        }
    }
    
    func logout() {
        // 로그아웃 로직을 여기에 추가
    }
}

struct ProfileView: View {
    var body: some View {
        Text("프로필 화면")
            .navigationBarTitle("프로필", displayMode: .inline)
    }
}

#Preview {
    ContentView()
    //TimetableView()
}
