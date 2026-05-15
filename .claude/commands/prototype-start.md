---
description: 프로토타입 빌드 루프 시작 — 게이트 검증 + 엔진 선택 후 Round 0.1~0.5 자동 빌드 (v0.6+, 완료 시 메뉴부터 1주기 플레이 가능)
model: sonnet
---

prototype-build-loop 스킬을 호출하여 Round 0 (auto-build) 진입. `auto-build-orchestrator.md` 가 substep 5개를 자동 연쇄:

1. 활성 프로젝트의 단계 7 게이트 통과 + 산출물 4종 (SSOT, art-bible, tech-spec, changelog) 존재 검증 — 결과를 사용자에게 1블록으로 표면화
2. 진입 조건 검증: `state.yaml.build_state.current_round` null + `build/` 비어있음 (기존 프로젝트는 자동 빌드 ✕, 기존 roundN-patch 진입)
3. 엔진 선택: Godot 4 / Unity 6 (**무조건 사용자 응답 대기**, 1회)
4. `engines/{선택}.md` 어댑터 로드·검증
5. **Round 0.1**: 엔진 init + tech-spec §F·§G 스캐폴드 → commit + ITERATION_LOG v0.1
6. **Round 0.2**: SSOT §B 코어 메카닉 1 cycle 최소 구현 → commit + v0.2
7. **Round 0.3**: SSOT §C 전체 시스템 + §I AC 테스트 일괄 → commit + v0.3
8. **Round 0.4**: SSOT §D UX 진입로 + §G 콘텐츠 인스턴스 일괄 등록 → commit + v0.4
9. **Round 0.5**: `tools/gen_placeholders.py` 호출, art-bible §Z 슬롯 → PNG + sibling prompt.md → commit + v0.5
10. state.yaml.build_state.auto_build_status = "completed", current_round = 0
11. 최종 보고 (엔진 / §F 모듈 / §B 코어 루프 / §C 시스템 / AC pass-fail / §D UX / §G 콘텐츠 / 1주기 smoke / art 슬롯) — **사용자가 build/{engine}/ 에서 직접 빌드해 메뉴부터 1주기까지 플레이 가능**

전제:
- 단계 7 미통과 시 거부 + 누락 산출물 안내
- substep 당 자동 재시도 2회 — 모두 실패 시 사용자에게 2 옵션 (수동 전환·롤백) 제시

자세한 절차: `prompts/prototype-build-loop/auto-build-orchestrator.md`. spec: `docs/superpowers/specs/2026-05-11-auto-build-substeps-design.md` (4-substep v0.5 까지의 설계 — 5-substep v0.6 확장은 SKILL.md / orchestrator / pipeline.yaml changelog 참조).
