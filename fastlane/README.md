fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

TestFlight 에 올린다 (내부 테스터 — 베타 심사 없음)

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store 에 올리고 심사까지 제출한다

### ios build_only

```sh
[bundle exec] fastlane ios build_only
```

빌드만 해 본다 — 올리지 않는다

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
