---
description: 프로토타입 빌드 루프 시작 — 엔진 선택 후 Round 0.1~0.4 자동 빌드 (v0.5+)
model: sonnet
---

prototype-build-loop 스킬을 호출하여 Round 0 (auto-build) 진입. `auto-build-orchestrator.md` 가 substep 4개를 자동 연쇄:

1. 활성 프로젝트의 단계 7 게이트 통과 + 산출물 4종 (SSOT, art-bible, tech-spec, changelog) 존재 검증
2. 진입 조건 검증: `state.yaml.build_state.current_round` null + `build/` 비어있음 (기존 프로젝트는 자동 빌드 ✕, 기존 roundN-patch 진입)
3. 엔진 선택: Godot 4 / Unity 6 (사용자 응답 대기, 1회)
4. `engines/{선택}.md` 어댑터 로드·검증
5. **Round 0.1**: 엔진 init + tech-spec §F·§G 스캐폴드 → commit + ITERATION_LOG v0.1
6. **Round 0.2**: SSOT §B 코어 메카닉 1 cycle 최소 구현 → commit + v0.2
7. **Round 0.3**: AC1 필수 §C 시스템 + 테스트 인프라 (stop 라인) → commit + v0.3
8. **Round 0.4**: `tools/gen_placeholders.py` 호출, art-bible §Z 슬롯 → PNG + sibling prompt.md → commit + v0.4
9. state.yaml.build_state.auto_build_status = "completed", current_round = 0
10. 최종 보고 (엔진/모듈/코어 루프/§C/AC1 결과/art 슬롯)

전제:
- 단계 7 미통과 시 거부 + 누락 산출물 안내
- substep 중간 실패 시 3 옵션 (재개·수동 전환·롤백) 제시, 자가 디버그 무한 루프 가드 (substep 당 재시도 1회)

자세한 절차: `prompts/prototype-build-loop/auto-build-orchestrator.md`. spec: `docs/superpowers/specs/2026-05-11-auto-build-substeps-design.md`.
