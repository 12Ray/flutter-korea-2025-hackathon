# MetaNote — MVP 설계서 & README

> **MetaNote**
> "문장이 아니라 생각의 연결을 그리는 노트" — 글을 쓰면 AI가 핵심 개념을 추출하고, 그것을 노드 그래프로 시각화하여 사용자의 사고 패턴을 보여주는 Flutter 앱

---

## 목차
1. 프로젝트 개요
2. 핵심 기능 (MVP)
3. 화면별 와이어프레임 & 사용자 흐름
4. 아키텍처 & 파일 구조
5. 핵심 기술 스택 / 패키지
6. 데이터 모델 / 로컬 저장 포맷
7. OpenAI (GPT) 통신 규약 예시
8. 핵심 코드 스니펫
9. 실행 방법 (개발환경) 및 빌드
10. 프라이버시 / 보안 노트
11. 발표(데모) 스크립트 & 슬라이드 체크리스트
12. 향후 확장 아이디어
13. 기여 / 라이선스

---

## 1) 프로젝트 개요
**MetaNote**는 사용자가 자유롭게 텍스트를 입력하면, 내부적으로 AI(GPT)가 텍스트를 분석하여 **핵심 개념(노드)** 과 **개념 간 관계(엣지)** 를 JSON 형태로 반환합니다. 프론트엔드는 이 결과를 받아 Flutter의 `CustomPainter` 기반 그래프에 노드/엣지로 렌더링합니다. 사용자는 터치로 노드를 이동·확장·편집할 수 있고, 하루/주 단위로 '사고 지도'를 저장하고 비교할 수 있습니다.

핵심 가치: **생각을 시각화하여 인사이트를 얻는 경험 제공**

---

## 2) 핵심 기능 (MVP)
- 텍스트 입력: 한 문단 또는 짧은 메모 입력
- AI 개념 추출: GPT로 핵심 키워드 + 관계 + 감정(senti) 추출
- 노드 그래프 렌더링: 노드/엣지 자동 배치(간단한 포스 레이아웃)
- 노드 조작: 드래그, 탭(확장), 롱프레스(삭제/편집)
- 저장: 로컬 DB에 날짜별 저장(복원 및 비교)
- 리포트 뷰: 오늘의 키워드 Top, 감정 분포 차트

---

## 3) 화면별 와이어프레임 & 사용자 흐름
### A. 메인 화면 — Editor + Graph
- 상단 바: 날짜, 저장 버튼, 리포트 버튼
- 입력 영역: 여러 줄 TextField (확장 가능)
- AI 버튼: "생각 지도 생성"
- 그래프 영역: 화면 절반 이상을 차지하는 Canvas (노드 그래프 렌더링)
- FAB: 새 노트

### B. Graph Interaction
- 노드 탭: 토스트형 툴팁(빈도, 감정, 관련 문장) 표시
- 노드 드래그: physics-based 충돌 회피(간단한 힘 기반 레이아웃)
- 엣지 강조: weight(강도)에 따라 선 굵기 조정

### C. Report 화면
- Top keywords (bar chart)
- Emotion ratio (pie chart)
- Connection heatmap (간단한 matrix or bar)

---

## 4) 아키텍처 & 파일 구조
```
lib/
 ├─ main.dart
 ├─ app.dart
 ├─ core/
 │   ├─ theme.dart
 │   └─ utils/
 ├─ features/
 │   ├─ editor/
 │   │   ├─ view/
 │   │   │   ├─ meta_note_page.dart
 │   │   │   ├─ text_input_panel.dart
 │   │   │   └─ node_graph_canvas.dart
 │   │   ├─ provider/
 │   │   │   ├─ note_provider.dart
 │   │   │   └─ ai_provider.dart
 │   │   ├─ model/
 │   │   │   ├─ node_model.dart
 │   │   │   └─ edge_model.dart
 │   │   └─ data/
 │   │       ├─ meta_note_repository.dart
 │   │       └─ local_storage.dart
 │   └─ report/
 │       └─ view/report_page.dart
 └─ services/
     └─ openai_service.dart

assets/
  └─ images/

```

---

## 5) 핵심 기술 스택 / 패키지
- Flutter 3.x
- State: Riverpod 3.0
- HTTP: Dio
- Local DB: Hive (또는 Drift) — 해커톤에는 Hive가 가볍고 빠름
- Graph rendering: CustomPainter (직접 구현) 또는 `graphview` (보조)
- Charts: fl_chart
- Animations: flutter_animate (선택)
- AI: Google Gemini 1.5 Flash

---

## 6) 데이터 모델 / 로컬 저장 포맷
- Node model
```dart
class NodeModel {
  final String id;
  final String label;
  final double x;
  final double y;
  final String emotion; // e.g. positive, neutral, negative
  final int freq; // 등장 횟수
}
```
- Edge model
```dart
class EdgeModel {
  final String from;
  final String to;
  final double weight; // 관계 강도 0..1
}
```
- MetaNote document (저장 포맷)
```json
{
  "date": "2025-10-25",
  "nodes": [...],
  "edges": [...],
  "rawText": "...",
  "summary": "..."
}
```

---

## 7) OpenAI (GPT) 통신 규약 예시
- 요청: 사용자가 입력한 텍스트를 보내고, 정해진 JSON 스키마로 응답을 요청

**system prompt (요청 예시)**
```
You are a JSON generator. Extract up to 8 key concepts from the user text and list relations between them. Respond only in JSON with keys: concepts, relations, summary. For each concept include id, label, sentiment("positive"|"neutral"|"negative"), freqEstimate (int).
```

**user prompt (요청 예시)**
```
Text: "오늘은 해커톤 아이디어를 생각했는데 Flutter로 시각화하면 재밌을 것 같아..."
```

**expected response**
```json
{
  "concepts": [
    {"id":"n1","label":"Flutter","sentiment":"positive","freqEstimate":3},
    {"id":"n2","label":"시각화","sentiment":"positive","freqEstimate":2}
  ],
  "relations": [
    {"from":"n1","to":"n2","weight":0.9}
  ],
  "summary": "핵심: Flutter로 시각화 아이디어가 긍정적으로 언급됨"
}
```

---

## 8) 핵심 코드 스니펫
### A. Gemini API 호출 예시
```dart
// services/gemini_service.dart
class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  late final GenerativeModel _model;
  
  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1500,
      ),
    );
  }
  
  Future<ConceptExtractionResult> extractConcepts(String text) async {
    final prompt = '${_getSystemPrompt()}\n\nText: "$text"';
    final content = [Content.text(prompt)];
    
    final response = await _model.generateContent(content);
    return _parseResponse(response.text!, text);
  }
}
```

### B. CustomPainter (간단한 노드+엣지 그리기)
```dart
class NodeGraphPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;

  NodeGraphPainter(this.nodes, this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final e in edges) {
      final a = nodes.firstWhere((n) => n.id==e.from);
      final b = nodes.firstWhere((n) => n.id==e.to);
      edgePaint.strokeWidth = max(1.0, e.weight * 6);
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), edgePaint);
    }

    for (final n in nodes) {
      final circlePaint = Paint()..color = _colorFromEmotion(n.emotion);
      canvas.drawCircle(Offset(n.x, n.y), 28, circlePaint);
      final textSpan = TextSpan(text: n.label, style: TextStyle(color: Colors.white, fontSize:12));
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(n.x - tp.width/2, n.y - tp.height/2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

## 9) 실행 방법 (개발환경) 및 빌드
### 요구사항
- Flutter SDK (>=3.10)
- dart >=2.18
- OpenAI API Key (별도 발급 필요)

### 설치 및 실행
```bash
git clone <repo-url>
cd metanote
flutter pub get
```

### 🔑 환경변수 설정 (필수)
**⚠️ 중요: API 키를 코드에 직접 입력하지 마세요!**

#### Gemini API 키 발급
1. [Google AI Studio](https://makersuite.google.com/app/apikey) 접속
2. Google 계정으로 로그인
3. "Create API Key" 클릭 
4. 새 프로젝트 생성 또는 기존 프로젝트 선택
5. API 키 복사 및 안전한 곳에 보관

#### 방법 1: 실행 시 환경변수 전달 (권장)
```bash
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

#### 방법 2: IDE 설정 (VS Code/Android Studio)
**VS Code**: `.vscode/launch.json`
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "MetaNote",
      "request": "launch", 
      "type": "dart",
      "args": ["--dart-define=GEMINI_API_KEY=your_gemini_api_key_here"]
    }
  ]
}
```

**Android Studio**: Run Configuration → Additional run args:
```
--dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

#### 방법 3: 환경 파일 사용
```bash
# .env.example을 .env로 복사
cp .env.example .env

# .env 파일 편집하여 실제 API 키 입력
GEMINI_API_KEY=your_gemini_api_key_here
```

### 📱 실행
```bash
flutter run -d chrome # Web
flutter run -d emulator # Android/iOS
```

---

## 10) 프라이버시 / 보안 노트

### 🔒 **API 키 보안**
- **절대 API 키를 코드에 하드코딩하지 마세요**
- 환경변수 또는 외부 설정 파일을 사용하세요
- `.gitignore`에 API 키가 포함된 파일들을 반드시 추가하세요
```gitignore
# API Keys & Secrets
.env
*.key
.vscode/launch.json
# Gemini API 키가 포함된 모든 파일
```

### 📊 **데이터 처리 정책**
- **입력된 텍스트는 Google Gemini로 전송**되어 분석됩니다
- **민감한 정보 입력 금지**: 개인정보, 비밀번호, 기밀 문서, 의료 정보 등
- Google의 데이터 사용 정책을 확인하세요: https://policies.google.com/privacy

### 💾 **로컬 데이터 보안**
- 로컬 저장소(Hive) 데이터는 **AES 암호화** 권장
```dart
// Hive 암호화 예시
final encryptionKey = Hive.generateSecureKey();
await Hive.openBox('metanotes', encryptionCipher: HiveAesCipher(encryptionKey));
```

### 🌐 **네트워크 보안**
- HTTPS 통신 강제 (OpenAI API는 기본 HTTPS)
- 인증서 고정(Certificate Pinning) 권장 (배포 시)
- 네트워크 타임아웃 설정으로 DoS 공격 방지

### ⚠️ **사용 시 주의사항**
- 공공장소에서 사용 시 화면 노출 주의
- 디바이스 잠금 설정 권장
- 정기적인 앱 업데이트로 보안 패치 적용

---

## 11) 발표(데모) 스크립트 & 슬라이드 체크리스트
### 추천 데모 흐름 (총 6분)
1. (0:00~0:30) 한 문장 소개 — "MetaNote는 생각을 지도화합니다"
2. (0:30~1:30) **라이브 입력 데모**: 실제 문장 입력 → "생각 지도 생성"(AI 호출) → 그래프 생성 (핵심 장면)
3. (1:30~2:30) 상호작용: 노드 드래그, 노드 탭 → 툴팁, 노드 편집
4. (2:30~3:30) 리포트 화면: 오늘의 Top 키워드/감정 분포 시연
5. (3:30~4:30) 아키텍처 간단 설명(백엔드 AI 호출, 로컬 저장) + 핵심 기술 스택
6. (4:30~5:30) 확장 예시: 협업, AR/3D 시각화 (시연 영상/모형), Q&A 마무리

### 슬라이드 체크리스트
- 슬라이드1: 한줄 개요 + 팀 로고
- 슬라이드2: 문제정의(왜 기존 노트는 한계가 있는가)
- 슬라이드3: 솔루션(메타노트 핵심 컨셉)
- 슬라이드4: 라이브 데모(혹은 짧은 녹화 영상)
- 슬라이드5: 아키텍처(간단 다이어그램)
- 슬라이드6: 향후 계획 & 기술적 도전 과제
- 슬라이드7: 팀 소개 및 연락처

---

## 12) 향후 확장 아이디어 (우승 포인트)
- 실시간 공동 편집 & 그래프 병합 (협업)
- 개념 간 인과관계(논리적 연결) 모델 학습
- AR/3D로 사고지도 시각화
- 다양한 미디어 입력 (이미지, 파일) 지원

---

## 13) 기여 / 라이선스

### 📄 **라이선스**
- **MIT License** - 자유로운 사용, 수정, 배포 가능
- 상업적 이용 가능 (단, OpenAI API 사용료는 별도)

### 🤝 **기여 가이드라인**
- PR 및 이슈 환영
- 보안 관련 이슈는 공개 이슈 대신 **개인 메시지**로 연락
- API 키 등 민감한 정보가 포함된 PR은 즉시 거부됩니다

### ⚖️ **사용 약관**
- 본 소프트웨어 사용 시 Google Gemini의 이용 약관을 준수해야 합니다
- 불법적이거나 유해한 콘텐츠 생성에 사용을 금지합니다
- 사용자는 입력 데이터의 프라이버시에 대한 책임을 집니다

### 🆘 **지원 및 문의**
- 🐛 버그 리포트: GitHub Issues
- 💡 기능 제안: GitHub Discussions
- 🔒 보안 문제: [보안 담당자 이메일] (비공개)

---

## 부록: 발표용 체크리스트 (빠른 체킹)
- [ ] 🔑 API 키 환경변수 정상 설정 (절대 코드에 노출 금지)
- [ ] 📝 Demo 데이터 2개 준비(짧은 문장 1개, 긴 문단 1개)
- [ ] 🎥 녹화본(30s) 준비(네트워크 불안 시 대비)
- [ ] 📊 슬라이드 & 스피치 노트 완성
- [ ] 💾 로컬 저장된 샘플 노트 3개
- [ ] 🔒 .gitignore 파일에 민감 정보 파일 추가 확인
- [ ] 🌐 네트워크 연결 상태 확인 (Gemini API 호출 테스트)

## 🚨 **Public 레포지토리 체크리스트**
- [ ] ✅ API 키가 코드에 하드코딩되지 않았는지 확인
- [ ] ✅ .gitignore에 민감한 설정 파일들이 포함되어 있는지 확인
- [ ] ✅ README에 보안 가이드가 명확히 작성되어 있는지 확인
- [ ] ✅ 환경변수 설정 방법이 자세히 안내되어 있는지 확인
- [ ] ✅ 라이선스 및 사용 약관이 명시되어 있는지 확인


---

마지막으로: README는 발표 자료의 핵심 보조 문서입니다. **데모에서 보여줄 핵심 장면(라이브 텍스트→그래프 생성)**을 README 시작부(또는 README 상단 GIF/이미지)로 배치하면 심사위원 임팩트가 커집니다.


---

