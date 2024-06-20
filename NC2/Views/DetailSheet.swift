//
//  DetailSheet.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI
import NaturalLanguage
import CoreML

struct DetailSheet: View {
    let appLanguage = Bundle.main.preferredLocalizations.first
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var homeViewModel: HomeViewModel
    
    @StateObject private var speechRecognitionManager = SpeechRecognitionManager()
    @State private var isRecording = false
    
    @State var transaction: Transaction
    
    @State private var selectTypes = [NSLocalizedString("지출", comment: ""), NSLocalizedString("수입", comment: "")]
    @State private var selectedType: Int
    @State private var showDatePicker = false
    @State private var showCategoryPicker = false
    @State private var datePickerOffset: CGFloat = 0.0
    @State private var amountString: String = ""
    @FocusState private var isPlaceFieldFocused: Bool
    @State private var isEditingPlace = false
    @FocusState private var isPriceFieldFocused: Bool
    @FocusState private var isMemoFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertText = ""
    var isEdit: Bool
    
    @State private var placeGrayOpacity: Double = 0.0
    @State private var amountGrayOpacity: Double = 0.0
    @State private var dateGrayOpacity: Double = 0.0
    
    init(homeViewModel: HomeViewModel, transaction: Transaction, isEdit: Bool) {
        self.homeViewModel = homeViewModel
        self._transaction = State(initialValue: transaction)
        self._selectedType = State(initialValue: transaction.transactionType == .outcome ? 0 : 1)
        self.isEdit = isEdit
    }

    var body: some View {
        ZStack {
            Color.lightGray.ignoresSafeArea()
                .onTapGesture{
                    isPlaceFieldFocused = false
                    isEditingPlace = false
                    showDatePicker = false
                    isPriceFieldFocused = false
                    isMemoFieldFocused = false
                }
            VStack {
                HStack {
                    Image(categoryIcon(transaction.category))
                        .resizable()
                        .frame(width: 28, height: 28)
                    HStack (spacing: 0) {
                        if (isEditingPlace) {
                            TextField("위치", text: $transaction.place)
                                .font(.Light16)
                                .fixedSize()
                                .focused($isPlaceFieldFocused)
                                .disabled(!isEditingPlace)
                                .onSubmit {
                                    isEditingPlace = false
                                    isPlaceFieldFocused = false
                                }
                                .onAppear {
                                    DispatchQueue.main.async {
                                        isPlaceFieldFocused = true
                                    }
                                }
                        } else {
                            TextField("위치", text: $transaction.place)
                                .font(.Light16)
                                .fixedSize()
                                .onTapGesture {
                                    isEditingPlace = true
                                    isPlaceFieldFocused = true
                                }
                        }
                        Image(systemName: "pencil.line").foregroundColor(.black)
                            .padding(.leading, 4)
                    }
                    .padding(4)
                    .background(Color.darkGray.opacity(placeGrayOpacity))
                    .cornerRadius(10)
                    .onTapGesture {
                        isEditingPlace = true
                        isPlaceFieldFocused = true
                    }
                    Spacer()
                    if isEdit {
                        Button(action: {
                            homeViewModel.removeItem(transaction)
                            dismiss()
                        }, label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        })
                    }
                }
                .padding(.top, 40)
                HStack {
                    HStack {
                        TextField("", text: $amountString, prompt: Text("0"))
                            .font(.SemiBold28)
                            .keyboardType(.numberPad)
                            .focused($isPriceFieldFocused)
                            .fixedSize()
                            .onChange(of: amountString) {
                                transaction.amount = Int(amountString.replacingOccurrences(of: ",", with: "")) ?? 0
                                amountString = addCommasToNumber(String(transaction.amount))
                            }
                            .onAppear {
                                amountString = addCommasToNumber(String(transaction.amount))
                                if amountString == "" {
                                    amountString = ""
                                }
                            }
                        Text("엔").font(.SemiBold28)
                    }
                    .padding(4)
                    .background(Color.darkGray.opacity(amountGrayOpacity))
                    .cornerRadius(10)
                    .onTapGesture {
                        isPriceFieldFocused = true
                    }
                    Spacer()
                    Picker(selection: self.$selectedType, label: Text("Pick One")) {
                        ForEach(Array(self.selectTypes.enumerated()), id: \.element) { index, element in
                            Text(element)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(self.selectedType == index ? Color.green : Color.gray)
                                .tag(index)
                        }
                    }
                    .onChange(of: selectedType) { newValue in
                        transaction.category = .none
                        transaction.transactionType = newValue == 0 ? .outcome : .income
                    }
                    .frame(width: 118)
                    .pickerStyle(SegmentedPickerStyle())
                }
                Spacer()
                HStack {
                    Text("일시").font(.SemiBold20).foregroundColor(.darkGray)
                    Spacer()
                    Button(action: {
                        withAnimation (.easeInOut(duration: 0.1))  {
                            self.showDatePicker.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("\(transaction.displayDate, formatter: dateFormatter)").font(.Light16).foregroundColor(.black)
                            Image(systemName: "chevron.down").foregroundColor(.customBlue)
                        }
                    })
                    .padding(4)
                    .background(Color.darkGray.opacity(dateGrayOpacity))
                    .cornerRadius(10)
                }
                Spacer()
                HStack {
                    Text("카테고리").font(.SemiBold20).foregroundColor(.darkGray)
                    Spacer()
                    Button {
                        withAnimation {
                            self.showCategoryPicker.toggle()
                        }
                    } label: {
                        Image(categoryIcon(transaction.category))
                            .resizable()
                            .frame(width: 28, height: 28)
                        Image(systemName: "chevron.down").foregroundColor(.customBlue)
                    }
                }
                Spacer()
                HStack {
                    Text("메모").font(.SemiBold20).foregroundColor(.darkGray)
                    Spacer()
                }
                TextField("", text: $transaction.memo)
                    .frame(height: 40)
                    .padding()
                    .focused($isMemoFieldFocused)
                    .background(Color(hexColor: "D9D9D9"))
                    .cornerRadius(10)
                    .onTapGesture {
                        isMemoFieldFocused = true
                    }
                Spacer()
                VStack (spacing: 0) {
                    if !isRecording {
                        Text("버튼을 눌러서 음성으로 내역을 기록해보세요.")
                            .font(.Medium12)
                            .foregroundColor(.darkGray)
                        Text("(날짜, 장소, 금액)")
                            .font(.Medium12)
                            .foregroundColor(.darkGray)
                            .padding(.bottom, 10)
                    } else {
                        Text("듣고 있어요...")
                            .font(.SemiBold26)
                            .foregroundColor(.customBlue)
                            .padding(.bottom, 10)
                    }
                }
                .frame(height: 40)
                if (speechRecognitionManager.recognizedText.isEmpty) {
                    Text("예시) 편의점에서 300엔")
                        .font(.Light18)
                        .foregroundColor(.darkGray)
                        .padding(.vertical, 8)
                } else {
                    Text(speechRecognitionManager.recognizedText)
                        .font(.Light18)
                        .padding(.vertical, 8)
                }
                HStack {
                    Button(action: {
                        if isRecording {
                            speechRecognitionManager.stopRecording()
                        } else {
                            speechRecognitionManager.startRecording()
                            speechRecognitionManager.recognizedText = ""
                        }
                        isRecording.toggle()
                    }) {
                        ZStack {
                            if isRecording {
                                Circle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.customBlue.opacity(0.3))
                                Circle()
                                    .stroke(Color.customBlue, lineWidth: 1)
                                    .frame(width: 114, height: 114)
                            }
                            Image("voice-bubble")
                            Image(systemName: "waveform")
                                .foregroundColor(.customBlue)
                        }
                        .padding()
                        .frame(width: 115, height: 115)
                    }
                }
                .padding(.bottom, 20)
                Button(action: {
                    print(transaction.amount)
                    if transaction.place == "" {
                        alertText = NSLocalizedString("장소를 입력하세요!", comment: "")
                        showAlert = true
                    } else if transaction.amount == 0 {
                        alertText = NSLocalizedString("금액을 입력하세요!", comment: "")
                        showAlert = true
                    } else {
                        printTransaction()
                        if isEdit {
                            homeViewModel.updateTransaction(transaction)
                        } else {
                            homeViewModel.appendItem(transaction: transaction)
                        }
                        dismiss()
                    }
                }) {
                    Text("완료")
                        .font(.SemiBold16)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customBlue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertText),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
            .padding(.horizontal, 26)
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPicker(selectedCategory: $transaction.category, selectedType: $selectedType)
            }
            .overlay(
                VStack {
                    Spacer()
                    if showDatePicker {
                        DatePicker("", selection: $transaction.displayDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                            .onChange(of: transaction.displayDate) {
                                withAnimation (.easeInOut(duration: 0.1)) {
                                    showDatePicker = false
                                }
                            }
                    }
                    Spacer()
                }
            )
        }
        .ignoresSafeArea(.keyboard)
        .dontAdaptsToKeyboard()
        .ignoresSafeArea()
        .presentationDragIndicator(.visible)
        .onChange(of: isPlaceFieldFocused) { newValue in
            if (!newValue) {
                isEditingPlace = false
            }
        }
        .onChange(of: speechRecognitionManager.recognizedText) {
            var taggedTextDic: [String: [String]] = [:]
            if appLanguage == "ko" {
                taggedTextDic = textToTagsKR(speechRecognitionManager.recognizedText)
            } else if appLanguage == "ja" {
                taggedTextDic = textToTagsJP(speechRecognitionManager.recognizedText)
            }
            taggedTextDic.forEach { (key: String, value: [String]) in
                if key == "Location" {
                    if value[0] != transaction.place {
                        placeGrayOpacity = 1
                        withAnimation {
                            placeGrayOpacity = 0
                        }
                        transaction.place = value[0]
                    }
                } else if key == "Amount" {
                    var recognizedNumber = extractNumbers(from: value[0])
                    if recognizedNumber != transaction.amount {
                        amountGrayOpacity = 1
                        withAnimation {
                            amountGrayOpacity = 0
                        }
                        transaction.amount = recognizedNumber
                        amountString = String(recognizedNumber)
                    }
                } else if key == "Date" {
                    if let updatedDate = updateDate(from: value[0]) {
                        dateGrayOpacity = 1
                        withAnimation {
                            dateGrayOpacity = 0
                        }
                        transaction.displayDate = updatedDate
//                        print("Updated date: \(updatedDate)")
                    }
                } else if key == "Verb" {
                    print(value)
                } else if key == "0" {
                    print("0")
                }
            }
            // 잘못된 숫자가 인식되어 Date가 미리 지정된 경우, 현재로 되돌리는 코드 (Date가 없을 경우에만)
            if !taggedTextDic.keys.contains("Date") {
                transaction.displayDate = Date()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd EEE"
        return formatter
    }
    
    private func printTransaction() {
        print("Transaction: \(transaction)")
    }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: CategoryType
    @Binding var selectedType: Int
    @Environment(\.presentationMode) var presentationMode
    
    let outcomeCategories: [CategoryType] = [
        .none, .food, .education, .drink, .cafe, .store, .shopping, .hospital, .travel
    ]
    
    let incomeCategories: [CategoryType] = [
        .none, .allowance, .education, .education, .interest, .insurance
    ]
    
    func categoryName(_ category: CategoryType) -> String {
        switch category {
        case .none:
            return "미등록"
        case .food:
            return "식당"
        case .education:
            return "교육"
        case .drink:
            return "바"
        case .cafe:
            return "카페"
        case .store:
            return "편의점"
        case .shopping:
            return "쇼핑"
        case .hospital:
            return "병원"
        case .travel:
            return "여행"
        case .allowance:
            return "용돈"
        case .salary:
            return "월급"
        case .interest:
            return "이자"
        case .insurance:
            return "보험"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(selectedType == 0 ? outcomeCategories : incomeCategories, id: \.self) { category in
                HStack {
                    Spacer()
                    Image(categoryIcon(category))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 30)
                    HStack {
                        Text(categoryName(category))
                            .font(.Medium14)
                        Spacer()
                    }
                    .frame(maxWidth: 80)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = category
                    presentationMode.wrappedValue.dismiss()
                }
                
                Divider()
            }
        }
        .ignoresSafeArea(.keyboard)
        .cornerRadius(10)
        .presentationDetents([.height(selectedType == 0 ? 560 : 380)])
    }
}

func addCommasToNumber(_ input: String) -> String {
    let numberWithoutCommas = input.replacingOccurrences(of: ",", with: "")
    if let number = Int(numberWithoutCommas) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number)) ?? input
    }
    return input
}

func textToTagsJP(_ text: String) -> [String: [String]] {
    do {
        let mlModel = try MoneySpeechModelJP(configuration: MLModelConfiguration()).model

        let customModel = try NLModel(mlModel: mlModel)
        let customTagScheme = NLTagScheme("MoneySpeechModelJP")
        
        let tagger = NLTagger(tagSchemes: [.nameType, customTagScheme])
        tagger.string = text
        tagger.setModels([customModel], forTagScheme: customTagScheme)
        
        var tagsDict: [String: [String]] = [:]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: customTagScheme, options: .omitWhitespace) { tag, tokenRange in
            if let tag = tag {
                let tagValue = tag.rawValue
                let token = String(text[tokenRange])
                
                if tagsDict[tagValue] != nil {
                    tagsDict[tagValue]?.append(token)
                } else {
                    tagsDict[tagValue] = [token]
                }
            }
            return true
        }
        
        for (key, tokens) in tagsDict {
            tagsDict[key] = [tokens.joined()]
        }
        
        print(tagsDict)
        return(tagsDict)
    } catch {
        print(error)
        return [:]
    }
}

func textToTagsKR(_ text: String) -> [String: [String]] {
    do {
        let mlModel = try MoneySpeechModelKR(configuration: MLModelConfiguration()).model

        let customModel = try NLModel(mlModel: mlModel)
        let customTagScheme = NLTagScheme("MoneySpeechModelKR")
        
        let tagger = NLTagger(tagSchemes: [.nameType, customTagScheme])
        tagger.string = text
        tagger.setModels([customModel], forTagScheme: customTagScheme)
        
        var tagsDict: [String: [String]] = [:]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: customTagScheme, options: .omitWhitespace) { tag, tokenRange in
            if let tag = tag {
                let tagValue = tag.rawValue
                let token = String(text[tokenRange])
                
                if tagsDict[tagValue] != nil {
                    tagsDict[tagValue]?.append(token)
                } else {
                    tagsDict[tagValue] = [token]
                }
            }
            return true
        }
        
        for (key, tokens) in tagsDict {
            var joinedString = tokens.joined()
            
            if key == "Location" {
                let suffixesToRemove = ["을", "를", "에서"]
                for suffix in suffixesToRemove {
                    if joinedString.hasSuffix(suffix) {
                        joinedString = String(joinedString.dropLast(suffix.count))
                        break
                    }
                }
            } else if key == "Date" {
                let suffixesToRemove = ["에", "날"]
                for suffix in suffixesToRemove {
                    if joinedString.hasSuffix(suffix) {
                        joinedString = String(joinedString.dropLast(suffix.count))
                    }
                }
                joinedString = joinedString.replacingOccurrences(of: " ", with: "")
            }
            
            tagsDict[key] = [joinedString]
        }
        
        print(tagsDict)
        return(tagsDict)
    } catch {
        print(error)
        return [:]
    }
}

func extractNumbers(from text: String) -> Int {
    let numbers = text.filter { "0123456789".contains($0) }
    return Int(numbers) ?? 0
}

func updateDate(from value: String) -> Date? {
    let currentYear = Calendar.current.component(.year, from: Date())
    let currentMonth = Calendar.current.component(.month, from: Date())
    let currentDate = Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: NSLocalizedString("ko_KR", comment: ""))
    
    if let fullDate = getDate(from: value, using: NSLocalizedString("yyyy년M월d일", comment: "")), fullDate <= currentDate {
        return fullDate
    } else if let monthDay = getDate(from: "\(currentYear)\(NSLocalizedString("년", comment: ""))\(value)", using: NSLocalizedString("yyyy년M월d일", comment: "")), monthDay <= currentDate {
        return monthDay
    } else if let dayOnly = getDate(from: "\(currentYear)\(NSLocalizedString("년", comment: ""))\(currentMonth)\(NSLocalizedString("월", comment: ""))\(value)", using: NSLocalizedString("yyyy년M월d일", comment: "")), dayOnly <= currentDate {
        return dayOnly
    }
    
    return nil
}


func getDate(from value: String, using format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: value)
}
