# 팀 프로젝트: 스포츠 매칭 시스템

## 팀명: **but_eo**
- **소속**: 영진전문대 5조

---

## 📍 프로젝트 개요
우리는 다양한 스포츠 종목을 매칭해주는 시스템을 만들 계획입니다.  
다양한 스포츠를 즐기는 사람들이 쉽고 빠르게 매칭되어 함께 즐길 수 있도록 도와주는 플랫폼을 개발할 것입니다.

## 🎮 매칭 가능한 스포츠
- **축구**
- **탁구**
- **풋살**
- **농구**
- **배드민턴**
- **테니스**
  
이 외에도 다양한 스포츠 매칭을 지원할 예정입니다!

---

## 🔧 기술 스택
- **프론트엔드**: flutter, HTML, CSS , javascript
- **백엔드**: java, springboot
- **데이터베이스**:  MySQL
- **버전 관리**: Git, GitHub
- **서버**: AWS 

## 🎯 목표
이 프로젝트의 목표는 사용자가 원하는 스포츠 종목에 맞춰 빠르게 매칭하고, 보다 나은 스포츠 경험을 제공하는 것입니다. 사용자 인터페이스(UI)를 직관적으로 만들어 누구나 쉽게 이용할 수 있도록 할 예정입니다.

---

## 🚀 진행 계획
1. **기초 설계 및 DB 구조 설계**
2. **매칭 알고리즘 개발**
3. **프론트엔드 디자인 및 기능 구현**
4. **백엔드 API 개발 및 통합**
5. **테스트 및 배포**

프로젝트 진행 중에는 주기적으로 **GitHub**을 통해 협업하며, 각자의 역할을 맡아 효율적으로 개발을 진행할 것입니다.

---

### 함께 만들어가는 **but_eo** 팀의 스포츠 매칭 시스템, 기대해 주세요! ✨





# 🛡️ GitHub Branch Protection & Workflow Rules

우리 팀은 협업 효율성과 코드 안정성을 높이기 위해 다음과 같은 GitHub 브랜치 전략 및 보호 규칙을 적용합니다.

---

## 🌿 브랜치 전략

### 1. `main`
- 실제 서비스에 배포되는 최종 코드
- **직접 커밋 금지**, 오직 PR을 통해서만 병합 가능

### 2. `develop`
- 개발 중인 코드가 모이는 브랜치
- 기능 브랜치에서 작업 완료 후 PR로 merge
- main 병합 전 마지막 테스트 진행

### 3. 기능 브랜치들 (예: `feature/login`, `fix/token-bug` 등)
- 기능별로 개별 생성하고 작업 완료 시 `develop`으로 PR

```bash
# 브랜치 네이밍 컨벤션
feature/<기능명>
fix/<버그설명>
docs/<문서변경>
refactor/<리팩토링내용>
chore/<잡일>
```

---

## ✅ 브랜치 보호 규칙

### 적용 브랜치
- `main`
- `develop`

### 적용 규칙
- [x] Force push 금지
- [x] 브랜치 삭제 금지
- [x] PR 없이 직접 push 금지 (Require a pull request before merging)
- [x] 브랜치 생성 제한 (관리자만 생성 가능)

### 병합 방식
- `Merge`, `Squash`, `Rebase` 모두 허용

---

## 🔍 PR 체크리스트 템플릿 (자동 적용)
- [ ] 기능 정상 작동 여부 확인
- [ ] 커밋 메시지 컨벤션 준수
- [ ] 코드 리뷰어 지정
- [ ] 필요시 문서 작성
- [ ] 관련 이슈와 연결

---

## 📁 기타
- 자세한 PR 양식은 `.github/PULL_REQUEST_TEMPLATE.md` 참고
- 브랜치 규칙은 `Settings > Rules > Rulesets`에서 관리

---

문의 또는 예외 요청은 `@ohsang14` 에게 주세요 😄


