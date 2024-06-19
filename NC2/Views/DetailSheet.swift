//
//  DetailSheet.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct DetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var homeViewModel: HomeViewModel
    
    @State var transaction: Transaction
    @State private var selectTypes = ["지출", "수입"]
    @State private var selectedType: Int
    @State private var showDatePicker = false
    @State private var showCategoryPicker = false
    @State private var datePickerOffset: CGFloat = 0.0
    @State private var amountString: String = ""
    @FocusState private var isPlaceFieldFocused: Bool
    @State private var isEditingPlace = false
    @FocusState private var isPriceFieldFocused: Bool
    @State private var showAlert = false // State for showing alert
    var isEdit: Bool

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
                }
            VStack {
                Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 35, height: 5)
                    .padding(6)
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
                                .disabled(true)
                        }
                        Image(systemName: "pencil.line").foregroundColor(.black)
                            .padding(.leading, 4)
                    }
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
                .padding(.top, 20)
                HStack {
                    HStack {
                        TextField("", text: $amountString, prompt: Text("0"))
                            .font(.SemiBold28)
                            .keyboardType(.numberPad)
                            .focused($isPriceFieldFocused)
                            .fixedSize()
                            .onChange(of: amountString) { _ in
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
                    .frame(height: 80)
                    .background(Color(hexColor: "D9D9D9"))
                    .cornerRadius(10)
                Spacer()
                Text("버튼을 눌러서 음성으로 내역을 기록해보세요.")
                    .font(.Medium12)
                    .foregroundColor(.darkGray)
                Text("(날짜, 장소, 금액)")
                    .font(.Medium12)
                    .foregroundColor(.darkGray)
                    .padding(.bottom, 10)
                Text("예시) 패밀리마트에서 300엔")
                    .font(.Light18)
                    .foregroundColor(.darkGray)
                Spacer()
                Button(action: {
                    if transaction.amount == 0 {
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
                        title: Text("금액을 입력하세요!"),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
            .padding(.horizontal, 26)
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPicker(selectedCategory: $transaction.category)
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
        .onChange(of: isPlaceFieldFocused) { newValue in
            if (!newValue) {
                isEditingPlace = false
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
    @Environment(\.presentationMode) var presentationMode
    
    let categories: [CategoryType] = [
        .none, .food, .education, .drink, .cafe, .store, .shopping, .hospital, .travel
    ]
    
    func categoryName(_ category: CategoryType) -> String {
        switch category {
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
        case .none:
            return "미등록"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(categories, id: \.self) { category in
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
        .cornerRadius(10)
        .presentationDetents([.height(560)])
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
