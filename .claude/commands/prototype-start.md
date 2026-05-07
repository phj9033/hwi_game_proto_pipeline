---
description: 프로토타입 빌드 루프 시작 — 엔진 선택 후 Round 0 (L4 스캐폴드) 생성
model: sonnet
---

prototype-build-loop 스킬을 호출하여 Round 0 진입:

1. 활성 프로젝트의 단계 7 게이트 통과 + 산출물 4종 (SSOT, art-bible, tech-spec, changelog) 존재 검증
2. 엔진 선택: Godot 4 / Unity 6 (사용자 응답 대기)
3. `engines/{선택}.md` 어댑터 로드·검증
4. 스캐폴드 계획 표시 + 사용자 확인
5. `workspace/<slug>/build/{engine}/` 생성 + git init
6. tech-spec §F·§G·§I 기반 L4 스캐폴드 (모듈 스텁·시그널·Resource·테스트 골격·코어 루프 placeholder)
7. ITERATION_LOG.md 에 v0 항목 (3 필드)
8. state.yaml.artifacts.engine, build_state 갱신

전제: 단계 7 미통과 시 거부 + 누락 산출물 안내.
