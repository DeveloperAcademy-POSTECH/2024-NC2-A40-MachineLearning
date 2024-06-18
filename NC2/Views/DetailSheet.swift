//
//  DetailSheet.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct DetailSheet: View {
    @State private var transaction = Transaction(
        place: "세븐일레븐",
        amount: 3000,
        transactionType: .outcome,
        displayDate: Date(),
        createDate: Date(),
        category: .food,
        memo: ""
    )
    
    @State private var selectTypes = ["지출", "수입"]
    @State private var selectedType = 0 {
        didSet {
            transaction.transactionType = selectedType == 0 ? .outcome : .income
        }
    }
    
    @State private var showDatePicker = false
    @State private var showCategoryPicker = false
    
    @State private var datePickerOffset: CGFloat = 0.0
    
    @State private var amountString: String = ""

    var body: some View {
        ZStack {
            Color.lightGray.ignoresSafeArea()
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
                    Text(transaction.place).font(.Light16)
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "pencil.line").foregroundColor(.black)
                    })
                    Spacer()
                }
                .padding(.top, 20)
                HStack {
                    TextField("0", text: $amountString)
                        .font(.SemiBold28)
                        .keyboardType(.numberPad)
                        .fixedSize()
                        .onChange(of: amountString) {
                            transaction.amount = Int(amountString.replacingOccurrences(of: ",", with: "")) ?? 0
                            amountString = addCommasToNumber(String(transaction.amount))
                        }
                        .onAppear {
                            amountString = addCommasToNumber(String(transaction.amount))
                        }
                    Text("엔").font(.SemiBold28)
                    Spacer()
                    Picker(selection: self.$selectedType, label: Text("Pick One")) {
                        ForEach(Array(self.selectTypes.enumerated()), id: \.element) { index, element in
                            Text(element)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(self.selectedType == index ? Color.green : Color.gray)
                                .tag(index)
                        }
                    }
                    .frame(width: 118)
                    .pickerStyle(SegmentedPickerStyle())
                }
                Spacer()
                HStack {
                    Text("일시").font(.SemiBold20).foregroundColor(.darkGray)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.showDatePicker.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("\(transaction.displayDate, formatter: dateFormatter)").font(.Light16).foregroundColor(.black)
                            Image(systemName: "chevron.down").foregroundColor(.customBlue)
                        }
                    })
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            DispatchQueue.main.async {
                                datePickerOffset = geometry.frame(in: .global).minY
                            }
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
                    printTransaction()
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
            }
            .padding(.horizontal, 26)
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPicker(selectedCategory: $transaction.category)
            }
            .overlay(
                VStack {
                    if showDatePicker {
                        DatePicker("", selection: $transaction.displayDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                            .offset(y: datePickerOffset)
                            .onChange(of: transaction.displayDate) {
                                withAnimation {
                                    showDatePicker = false
                                }
                            }
                    }
                    Spacer()
                }
            )
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

#Preview {
    DetailSheet()
}

struct CategoryPicker: View {
    @Binding var selectedCategory: CategoryType
    @Environment(\.presentationMode) var presentationMode
    
    let categories: [CategoryType] = [
        .food, .education, .drink, .cafe, .store, .shopping, .hospital, .travel
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
                }
                .padding()
                .background(Color.white)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = category
                    presentationMode.wrappedValue.dismiss()
                }
                Divider() // 각 항목 사이에 구분선을 추가
            }
        }
        .cornerRadius(10)
        .presentationDetents([.height(500)])
    }
}

#Preview {
    CategoryPicker(selectedCategory: .constant(.cafe))
}

// Custom presentationDetents for a specific height
extension PresentationDetent {
    static func setHeight(_ height: CGFloat) -> Self {
        Self.height(height)
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
