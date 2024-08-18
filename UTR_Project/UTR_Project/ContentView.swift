//
//  ContentView.swift
//  UTR_APP
//
//  Created by Neo on 8/8/24.
//

import SwiftUI

//ContentView
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
}

//MainPageView
struct MainPageView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimetableView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("시간표")
                }
                .tag(0)
            
            ExamAssignmentView()
                .tabItem {
                    Image(systemName: "book")
                    Text("시험/과제")
                }
                .tag(1)
            
            Text("오늘 알림")
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("오늘 알림")
                }
                .tag(2)
            
            Text("알림")
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("알림")
                }
                .tag(3)
            
            MyPage()
                .tabItem {
                    Image(systemName: "person")
                    Text("MY")
                }
                .tag(4)
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

//TimetableView
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
            
            TimetableGridView(timetableItems: $timetableItems)
                .padding(.top)
        }
        .padding()
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

//TimetableGridView
struct TimetableGridView: View {
    @Binding var timetableItems: [TimetableItem]
    @State private var selectedItem: TimetableItem?
    
    let days = ["월", "화", "수", "목", "금"]
    let hours = Array(9...20)
    
    var body: some View {
        GeometryReader { geometry in
            let gridWidth = (geometry.size.width - 50) / CGFloat(days.count)
            let gridHeight = (geometry.size.height - 50) / CGFloat(hours.count)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 50, height: gridHeight)
                        .background(Color.gray.opacity(0.2))
                    
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .frame(width: gridWidth, height: gridHeight)
                            .background(Color.gray.opacity(0.2))
                            .border(Color.black)
                    }
                }
                
                ForEach(hours, id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text("\(hour)")
                            .frame(width: 50, height: gridHeight)
                            .background(Color.gray.opacity(0.2))
                            .border(Color.black)
                        
                        ForEach(days.indices, id: \.self) { dayIndex in
                            ZStack {
                                Rectangle()
                                    .stroke(Color.gray)
                                    .frame(width: gridWidth, height: gridHeight)
                                
                                ForEach(timetableItems) { item in
                                    let startHour = Calendar.current.component(.hour, from: item.startTime)
                                    let endHour = Calendar.current.component(.hour, from: item.endTime)
                                    
                                    if item.dayIndex == dayIndex && (startHour <= hour && hour < endHour) {
                                        VStack {
                                            Text(item.title)
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
        }
        .sheet(item: $selectedItem) { item in
            TimetableDetailView(timetableItem: item, timetableItems: $timetableItems)
        }
        .padding(.bottom, 50)
    }
}

//TimetableDetailView
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

//AddTimetableView
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
}

//TimetableItem
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

//CodableColor
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
        color = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let (red, green, blue, opacity) = color.components()
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(opacity, forKey: .opacity)
    }
}

extension Color {
    func components() -> (red: Double, green: Double, blue: Double, opacity: Double) {
        let components = cgColor?.components
        return (red: Double(components?[0] ?? 0),
                green: Double(components?[1] ?? 0),
                blue: Double(components?[2] ?? 0),
                opacity: Double(components?[3] ?? 0))
    }
}

//TimetableListView
struct TimetableListView: View {
    var body: some View {
        VStack {
            HStack {
                Text("시간표")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Spacer()
                
                Button(action: {
                }) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.black)
                        .font(.title)
                        .padding()
                }
            }
            
            List {
                Text("1학년 1학기")
                
                Text("1학년 2학기")
                
                Text("2학년 1학기")
            }
        }
    }
}

//SettingsView
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
            .navigationBarTitle("환경설정")
        }
    }
    
    func logout() {
        // 로그아웃 로직을 여기에 추가
    }
}

//ProfileView
struct ProfileView: View {
    var body: some View {
        Text("프로필 화면")
            .navigationBarTitle("프로필", displayMode: .inline)
    }
}

#Preview {
    ContentView()
}
