//
//  MyPageData.swift
//  0808
//
//  Created by Neo on 8/18/24.
//
import SwiftUI

struct MyPageData {
    var Name: String
    var College: String
    var Class: String
    
    static let `default` = MyPageData(
        Name: "",
        College: "",
        Class: ""
    )
}

struct MyPage: View {
    @State private var mypagedata = MyPageData.default
    @State private var showingMyEditor = false
    
    var body: some View {
        NavigationStack {
            
            Spacer()
            
            List {
                
                Section(header: Text("프로필")) {
                    
                    HStack {
                        
                        Spacer()
                        Image("UTR")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(.black, lineWidth: 3)
                            }
                        Spacer()
                    }
                    .padding()
                }
                
                Section {
                    
                    HStack {
                        Text("이름")
                        Spacer()
                        Text(mypagedata.Name)
                        
                    }
                    
                    HStack {
                        Text("대학교")
                        Spacer()
                        Text(mypagedata.College)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("학년")
                        Spacer()
                        Text(mypagedata.Class)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            //List
            .navigationTitle("MY")
            .toolbar {
                NavigationLink(destination: MyEditor(mypagedata: $mypagedata)) {
                    Text("Edit")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

struct MyEditor: View {
    @Binding var mypagedata: MyPageData
    @State private var tempName: String
    @State private var tempCollege: String
    @State private var tempClass: String
    @Environment(\.presentationMode) var presentationMode
    
    init(mypagedata: Binding<MyPageData>) {
        self._mypagedata = mypagedata
        self._tempName = State(initialValue: mypagedata.wrappedValue.Name)
        self._tempCollege = State(initialValue: mypagedata.wrappedValue.College)
        self._tempClass = State(initialValue: mypagedata.wrappedValue.Class)
    }
    
    var body: some View {
        NavigationStack {
            Image("UTR")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.black, lineWidth: 3)
                }
                .padding(50)
            
            List {
                Section {
                    HStack {
                        Text("이름")
                        Spacer()
                        TextField("입력", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("대학교")
                        Spacer()
                        TextField("입력", text: $tempCollege)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("학년")
                        Spacer()
                        TextField("입력", text: $tempClass)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("저장") {
                            mypagedata.Name = tempName
                            mypagedata.College = tempCollege
                            mypagedata.Class = tempClass
                            presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
                    }
                }
                .navigationTitle("데이터 수정")
            }
        }
    }
}

#Preview {
    MyPage()
}

