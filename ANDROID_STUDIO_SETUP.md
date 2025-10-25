# Android Studio Run Configuration Setup

Android Studio에서 MetaNote를 실행하기 위한 설정 방법:

## 1. Run Configuration 생성
1. Android Studio에서 프로젝트 열기
2. 상단 메뉴 → Run → Edit Configurations...
3. 좌측 상단 "+" 버튼 클릭 → Flutter 선택

## 2. Configuration 설정
- **Name**: MetaNote
- **Dart entrypoint**: lib/main.dart
- **Additional run args**: `--dart-define=GEMINI_API_KEY=your_gemini_api_key_here`
- **Build flavor**: (비워두기)
- **Target platform**: 원하는 플랫폼 선택

## 3. 여러 플랫폼 설정
### Android
- **Name**: MetaNote (Android)
- **Additional run args**: `--dart-define=GEMINI_API_KEY=your_gemini_api_key_here -d android`

### iOS
- **Name**: MetaNote (iOS)
- **Additional run args**: `--dart-define=GEMINI_API_KEY=your_gemini_api_key_here -d ios`

### Web
- **Name**: MetaNote (Web)
- **Additional run args**: `--dart-define=GEMINI_API_KEY=your_gemini_api_key_here -d chrome`

## 4. 환경 변수 대신 사용할 수 있는 방법
### 방법 1: gradle.properties (Android)
`android/gradle.properties`에 추가:
```properties
GEMINI_API_KEY=your_gemini_api_key_here
```

### 방법 2: xcconfig files (iOS)
`ios/Flutter/Debug.xcconfig`와 `ios/Flutter/Release.xcconfig`에 추가:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

## 주의사항
⚠️ 실제 API 키를 설정 파일에 입력할 때는 해당 파일들이 .gitignore에 포함되어 있는지 확인하세요!