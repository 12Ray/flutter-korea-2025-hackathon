# MetaNote 빠른 시작 가이드 🚀

## 📝 5분만에 시작하기

### 1️⃣ API 키 발급 (2분)
1. [Google AI Studio](https://makersuite.google.com/app/apikey) 접속
2. Google 계정으로 로그인
3. "Create API Key" 클릭
4. API 키 복사 📋

### 2️⃣ 프로젝트 설정 (1분)
```bash
git clone [이 저장소 URL]
cd metanote
flutter pub get
```

### 3️⃣ 실행 (2분)
```bash
flutter run --dart-define=GEMINI_API_KEY=복사한_API_키
```

## 🎯 첫 번째 테스트

앱 실행 후:
1. **텍스트 입력**: 
   ```
   "AI 기술로 교육을 혁신하고 싶다. 
   개인화된 학습과 실시간 피드백으로 
   모든 학생이 성장할 수 있게 하자."
   ```

2. **"생각 지도 생성"** 버튼 클릭 ⚡

3. **결과 확인**: 노드 그래프와 관계 시각화 🎨

4. **인터랙션**: 노드 드래그, 탭, 편집 해보기 ✋

## ⚠️ 문제 해결

### API 키 오류
```
Exception: Gemini API key not found
```
→ 환경변수 설정 확인

### 네트워크 오류
```
네트워크 연결 시간이 초과
```
→ 인터넷 연결 및 방화벽 확인

### 빌드 오류
```
pub get failed
```
→ Flutter 버전 확인 및 `flutter clean` 실행

## 🔗 유용한 링크
- 📖 [상세 README](README.md)
- 🔒 [보안 가이드](SECURITY.md) 
- 🐛 [이슈 리포트](https://github.com/your-repo/issues)
- 💬 [디스커션](https://github.com/your-repo/discussions)

---
🎉 **축하합니다!** MetaNote를 성공적으로 시작했습니다!