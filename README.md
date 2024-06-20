# 2024-NC2-M40-MachineLearning
![ppt_main](https://github.com/DeveloperAcademy-POSTECH/2024-NC2-A40-MachineLearning/assets/30366858/b198eb7b-abb2-466c-80f3-1460b232e992)

## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About Machine Learning
**프로세스**

1. 이미지, 텍스트, 표 등을 **Create ML**에 학습
2. **Core ML Model**이 이것을 통해 모델을 생성하거나, 외부 라이브러리를 사용한 후 Core ML 형식으로 변경
3. **Core ML**에서 Vision, 자연어 처리, Speech, 음성 인식 등을 해결
4. 앱에 적용

### Create ML

코드 작성 없이 맥에서 바로 Core ML 모델을 생성하고 학습시킬 수 있는 도구

### Core ML

머신러닝을 애플 플랫폼에서 쉽게 사용할 수 있는 프레임워크

## 🎯 What we focus on?

### 1. 음성 인식

음성을 분석해서 Text로 변환해주는 STT (Speech-to-Text)

### 2. 자연어 처리 (개체명 인식)

자연어 텍스트를 분석하고, 언어별 메타데이터를 추론

개체명 인식 예시

**개체명 인식: 언어적 태깅을 사용하여, 문자열의 개체명을 지정*

### 이 두 가지 부분에 집중한 이유

ML 기술 자체만을 중점적으로 보여주기보다, **우리 서비스에서 수단으로써 잘 활용해보자고 생각**

즉, 머신러닝으로 데이터 분석만을 하기보다 **실제 사용성에 적용하는 것에 초점**

→ ML에서 **어떠한 부분을 사용해야 우리의 목적을 달성**할 수 있을지를 고민

→ 사용자가 겪고 있는 **어려움을 해결해주자**는 의견에서 시작

**일본인들을 위한 가계부 어플**이라는 아이디어가 도출

**자연어 처리**를 이용한 음성 인식과, **문서 인식**을 이용한 영수증 인식 기술 선택


## 💼 Use Case
💁‍♀️ 날이 더워 시원한 음료를 사기 위해 편의점에 방문한 **평범한 일본인 대학생 유키상..**

평소대로 현금으로 음료를 계산하고 밖으로 나왔다. 

잊지 않고 가계부를 작성하기 위해 어플을 켰는데, 

땀이 날 정도로 더운 날씨에 거래 내역, 계산 방법, 금액까지 일일이 기입하기 너무나 귀찮다. 

가계부는 그 때 그 때 써야 안 잊어버리는데.. 

**더 편리하고 쉽게 기입할 수 있는 방법이 필요하다!**

---

### 솔루션 컨셉

### **`현금 사용으로 가계 내역 기록 과정이 귀찮은 일본인들이 쉽게 내역을 기록할 수 있게 해주자!`**

---

### 기술

- **음성 인식**을 이용해 음성을 분석해 텍스트로 변환해준다.
- **자연어 처리**를 이용한 텍스트 분석으로 기록에 필요한 데이터를 가져와준다.

---

### 체크포인트

*해당 유스케이스에서 사람들이 가치를 잘 느끼게 하기 위해서, 이 기술만의 어떤 특징, 장점이 두드러지게 활용되고 있나요?*

→ 어떻게 말을 해도 앱이 알아서 인식해서, 필요한 데이터를 입력해줘 사용자의 입력이 번거롭지 않다.

*어떤 유저에게 어떤 가치, 가능성과 효용이 전달되나요?*

→ 매일 거래 내역을 기록하고 싶은데 타이핑이 귀찮은 유저가 빠르고 편리하게 접근해서 기록할 수 있다.

## 🖼️ Prototype
(프로토타입과 설명 추가)

## 🛠️ About Code
CreateML을 통해 아래와 같은 문장 데이터를 라벨링 (약 300문장 학습)
```json
{
"tokens":  ["12월5일",  "에",  "도서관",  "에서",  "800엔"],
"labels":  ["Date",  "0",  "Location",  "0",  "Amount"]
},
{
"tokens":  ["３月２４日",  "友達",  "から",  "550円",  "もらった"],
"labels":  ["Date",  "Location",  "O",  "Amount",  "Verb"]
}
```

CreateML로 생성한 MoneySpeechModel을 코드에 적용하는 Swift 코드
```swift
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
```
