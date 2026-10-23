# Restore development after moving to C:

## Requirement analysis

Restore this checkout at `C:\Code\Logarithm\cya` with the same Flutter and
locked package versions used before the move. Preserve app behavior and the
local-first, native-thin capture path (PRD sections 3 and 9).

## Approach / design

Restore the missing Flutter 3.44.4 / Dart 3.12.2 SDK on C:, repair its PATH
entry, and regenerate location-dependent build and dependency metadata.
Keep the existing Android SDK at `D:\Android`, which is still present.
Do not upgrade packages or rewrite working source code to fix generated files.

## Steps

1. Inventory installed tools, stale paths, package cache, and build configuration.
2. Restore the recorded SDK from the official archive and verify its checksum.
3. Refresh local configuration and remove only reproducible project build caches.
4. Resolve locked dependencies, run analysis and tests, and build Android APKs.
5. Record results and remaining platform or device verification limits.

## Acceptance criteria

- Flutter and Dart resolve to existing SDK executables on C:.
- Dependency resolution preserves `pubspec.lock`.
- Active generated configuration no longer references the old checkout or SDK.
- Static analysis, the full test suite, and Android builds succeed.
- Document checks that cannot run on this Windows host.

## Risks & mitigations

Generated caches embed absolute paths: regenerate them with Flutter rather than
editing dependency internals. Android remains installed on D:, so retain valid
references to that SDK. Keep all source files, signing material, and device data.

## Outcome

Restored the exact SDK, repaired PATH/editor/local SDK configuration, and rebuilt
generated metadata. Locked dependency resolution, static analysis, all 183 tests,
Android debug and all three release ABI builds passed. Debug onboarding and native
capture were verified on the Android 14 emulator; release native capture also passed
against the existing encrypted store. See `BUILD_LOG.md` for details and limits.
Windows desktop still requires Visual Studio C++ tooling; iOS/macOS were not built
on this Windows host.
