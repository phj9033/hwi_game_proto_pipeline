---
engine: unity
version: "6.0"               # Unity 6 (LTS 가까움)
required_tools:
  - Unity                    # Unity Hub 또는 직접 설치
init_command: "(manual)"     # Unity Hub UI 또는 unity-hub CLI
---

## 모듈 매핑

- tech-spec §F 모듈 1 개 → 파일 1 개: `Assets/Scripts/<Module>.cs`
- 기본 부모 클래스: 모듈 분류에 따라 `MonoBehaviour` (씬 동작) / `ScriptableObject` (데이터) / 일반 클래스 (서비스)
- 모듈 간 의존: C# `event` 또는 UnityEvent 통한 약결합 + DI 컨테이너 (Zenject/VContainer 선택)

## 시그널 매핑

- tech-spec §G 시그널 → C# `static event Action<T>` 또는 `UnityEvent<T>` (인스펙터 노출 필요 시)
- 시그널명: PascalCase (C# 컨벤션)
- emit: `OnX?.Invoke(arg)`
- connect: `OnX += HandleX;`

## Resource 매핑

- tech-spec §G Resource → `[CreateAssetMenu] public class <Name>SO : ScriptableObject`
- 파일 형식: `.asset` 직렬화. 위치: `Assets/Resources/<Name>.asset`
- 인스펙터 노출: `[SerializeField] private Type field;`

## 테스트 매트릭스 형식

- 프레임워크: Unity Test Framework (NUnit 기반)
- 테스트 파일 위치: `Assets/Tests/EditMode/Test_<Module>.cs` (EditMode) / `Assets/Tests/PlayMode/...` (PlayMode)
- §I AC 1 개 → 테스트 메서드 1 개: `[Test] public void Ac_<id>()`
- 실행: Unity Editor → Test Runner 또는 `unity -batchmode -runTests`

## 에셋 로드 컨벤션

- Placeholder PNG 경로: `Assets/art/{slot_id}.png` (`build/{engine}/` 기준 상대)
- 로드 패턴: `Resources.Load<Sprite>("art/{slot_id}")` 또는 SerializeField 로 직접 Sprite 참조
- 교체 시: 동일 파일명·동일 경로면 코드 수정 ✕. sprite size 변경 시만 SpriteRenderer / Image 의 size 조정.
- art-bible §Z 슬롯 맵의 `통합 위치` 컬럼 = 호출처 (예: `SpeciesIcon.cs:MakeForSpecies`)

## 프로젝트 init 절차

1. Unity Hub 에서 신규 3D/2D Core 프로젝트 생성 (Unity 6 LTS 선택)
2. `Assets/Scripts/`, `Assets/Resources/`, `Assets/Tests/EditMode/`, `Assets/Tests/PlayMode/` 디렉토리 생성
3. Test Framework 패키지 추가 (Window → Package Manager → Test Framework)
4. `Assembly Definition` 파일 추가 (Tests 격리 위해)
5. `.gitignore` / `.editorconfig` 적용
6. `Packages/manifest.json` 에 필요 패키지 명시

## .gitignore 템플릿

```
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Mm]emoryCaptures/
[Uu]ser[Ss]ettings/
*.csproj
*.sln
*.suo
*.user
.vs/
.idea/
.DS_Store
```

## .editorconfig

```
root = true

[*.cs]
indent_style = space
indent_size = 4
charset = utf-8-bom
end_of_line = crlf
trim_trailing_whitespace = true
insert_final_newline = true

[*.{asset,prefab,unity,mat}]
indent_style = space
indent_size = 2
```
