# MetaNote 🧠✨

> **"문장이 아니라 생각의 연결을 그리는 노트"**  
> AI가 당신의 텍스트에서 핵심 개념을 추출하고, 노드 그래프로 시각화하여 사고 패턴을 보여줍니다.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Gemini](https://img.shields.io/badge/Google-Gemini-orange?logo=google)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey)

</div>

---

## 🚀 주요 기능

- 📝 **텍스트 입력**: 자유로운 생각과 아이디어 입력
- 🧠 **AI 개념 추출**: Google Gemini로 핵심 키워드와 관계 분석
- 🎨 **노드 그래프**: 인터랙티브한 시각화로 생각의 연결 표시
- 🎯 **노드 조작**: 드래그, 탭, 편집으로 그래프 커스터마이징
- 📊 **리포트**: 감정 분포와 키워드 분석 차트
- 💾 **로컬 저장**: 안전한 암호화 저장 (Hive)

---

## 🛠️ 기술 스택

| 카테고리 | 기술 |
|----------|------|
| **Framework** | Flutter 3.x |
| **State Management** | Riverpod 3.0+ |
| **AI Service** | Google Gemini API |
| **Local Database** | Hive (암호화 지원) |
| **Charts** | fl_chart |
| **Network** | Dio |
| **Architecture** | Clean Architecture |

---

## 📋 요구사항

- Flutter SDK >=3.10.0
- Dart >=3.0.0
- **Google Gemini API Key** ([발급 방법](#-api-키-발급))

---

## 🔑 API 키 발급

### Google Gemini API 키 발급

1. [Google AI Studio](https://makersuite.google.com/app/apikey)에 접속
2. Google 계정으로 로그인
3. "Create API Key" 클릭
4. 새 프로젝트를 만들거나 기존 프로젝트 선택
5. API 키 복사 및 안전한 곳에 보관

⚠️ **보안 주의사항**:
- API 키를 절대 코드에 하드코딩하지 마세요
- Public 저장소에 업로드하지 마세요
- 정기적으로 키를 교체하세요

---

## 🚀 설치 및 실행

### 1. 저장소 클론
```bash
git clone https://github.com/your-username/metanote.git
cd metanote
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 환경 변수 설정

#### 방법 1: 실행 시 직접 전달 (권장)
```bash
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

#### 방법 2: IDE 설정

**VS Code**: `.vscode/launch.json` 생성
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "MetaNote",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=GEMINI_API_KEY=your_gemini_api_key_here"
      ]
    }
  ]
}
```

**Android Studio**: 
- Run Configuration → Additional run args에 추가:
```
--dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

#### 방법 3: 환경 파일 사용
```bash
# .env.example을 .env로 복사
cp .env.example .env

# .env 파일 편집
GEMINI_API_KEY=your_gemini_api_key_here
```

### 4. 앱 실행
```bash
# 개발 모드
flutter run

# 특정 플랫폼
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS (시뮬레이터)
flutter run -d android         # Android (에뮬레이터)
```

---

## ⚡ 빠른 시작

1. **API 키 설정** 후 앱 실행
2. **텍스트 입력**: "오늘 Flutter로 해커톤 앱을 만들었다. AI와 시각화가 정말 흥미롭고 앞으로 더 공부하고 싶다."
3. **"생각 지도 생성"** 버튼 클릭
4. **노드 그래프** 확인 및 드래그로 조작
5. **리포트** 탭에서 분석 결과 확인

---

## 📱 사용법

### 기본 조작
- **노드 드래그**: 노드를 원하는 위치로 이동
- **노드 탭**: 상세 정보 툴팁 표시
- **노드 롱프레스**: 편집/삭제 메뉴
- **줌/팬**: 두 손가락으로 확대/축소 및 이동

### 고급 기능
- **저장**: 상단 저장 버튼으로 현재 상태 저장
- **불러오기**: 이전에 저장한 노트 복원
- **리포트**: 감정 분석 및 키워드 통계 확인

---

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 메인 앱 위젯
├── core/
│   └── theme.dart              # 앱 테마 설정
├── features/
│   ├── editor/
│   │   ├── model/              # 데이터 모델
│   │   ├── provider/           # 상태 관리
│   │   └── view/              # UI 컴포넌트
│   └── report/
│       └── view/              # 리포트 화면
└── services/
    └── gemini_service.dart    # Gemini API 통신
```

---

## 🔒 보안 및 프라이버시

### 데이터 보안
- **로컬 저장**: 모든 노트는 기기에만 저장
- **암호화**: Hive AES 암호화 지원
- **API 통신**: HTTPS 강제 사용

### 프라이버시 정책
- **외부 전송**: 입력한 텍스트만 Gemini API로 전송
- **데이터 수집**: 개인정보 수집하지 않음
- **사용 기록**: 로컬에만 저장, 외부 전송 없음

### 주의사항
⚠️ **민감한 정보 입력 금지**:
- 개인정보 (이름, 주소, 전화번호)
- 비밀번호 또는 인증 정보
- 기밀 문서 또는 사업 정보
- 의료 정보

---

## 🧪 테스트

```bash
# 단위 테스트 실행
flutter test

# 통합 테스트 실행
flutter test integration_test/

# 코드 분석
flutter analyze
```

---

## 🏆 데모 시나리오

### 해커톤 발표용 데모 흐름 (5분)

1. **소개** (0:30) - "MetaNote는 생각을 시각화합니다"
2. **라이브 데모** (2:00)
   ```
   입력: "AI 기술로 교육을 혁신하고 싶다. 
   개인화된 학습과 실시간 피드백으로 
   모든 학생이 자신만의 속도로 성장할 수 있게 하자."
   ```
3. **노드 조작** (1:30) - 드래그, 편집, 관계 확인
4. **리포트 화면** (1:00) - 감정 분석, 키워드 순위

---

## 🚀 배포

### Android APK 빌드
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### iOS IPA 빌드
```bash
flutter build ios --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### Web 빌드
```bash
flutter build web --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

---

## 🤝 기여하기

1. 이 저장소를 Fork
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 Push (`git push origin feature/amazing-feature`)
5. Pull Request 생성

### 코드 스타일
- `flutter analyze` 통과 필수
- `dart format` 적용
- 의미있는 커밋 메시지 작성

---

## 🐛 문제 해결

### 자주 발생하는 문제

#### 1. API 키 오류
```
Exception: Gemini API key not found
```
**해결**: 환경변수가 올바르게 설정되었는지 확인

#### 2. 네트워크 오류
```
Exception: 네트워크 연결 시간이 초과되었습니다
```
**해결**: 인터넷 연결 확인 및 방화벽 설정 점검

#### 3. 빌드 오류
```
Target of URI doesn't exist: 'package:google_generative_ai/...'
```
**해결**: `flutter pub get` 재실행

---

## 📞 지원

- 🐛 **버그 리포트**: [GitHub Issues](https://github.com/your-username/metanote/issues)
- 💡 **기능 제안**: [GitHub Discussions](https://github.com/your-username/metanote/discussions)
- 📧 **일반 문의**: your-email@example.com

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 🙏 감사의 말

- [Google Gemini](https://deepmind.google/technologies/gemini/) - AI 서비스 제공
- [Flutter Team](https://flutter.dev/) - 훌륭한 프레임워크
- [Riverpod](https://riverpod.dev/) - 강력한 상태 관리
- [fl_chart](https://pub.dev/packages/fl_chart) - 아름다운 차트 라이브러리

---

<div align="center">

**만든 사람들과 함께 만들어가는 MetaNote** 🚀

[⭐ Star](https://github.com/your-username/metanote) · [🍴 Fork](https://github.com/your-username/metanote/fork) · [📢 Issues](https://github.com/your-username/metanote/issues)

</div>
