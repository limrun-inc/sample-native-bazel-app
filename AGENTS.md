# Sample Native Bazel App

A native iOS app built with **Bazel** (`rules_apple` + `rules_swift`, bzlmod,
Bazel 9). It can be built and tested from any environment, including Linux,
using the `lim` CLI instead of a local Xcode toolchain.

- The app bundle ID is `com.limrun.sample-native-bazel`.
- The top-level build target is `//App:App`.
- This is a Bazel workspace (see `MODULE.bazel`), not an `.xcodeproj`.

During development you MUST build through Limrun RBE, never local Xcode or
`xcodebuild`.

## Cloud / Linux instructions

- Install the `lim` CLI: `npm install --global lim`.
- Authenticate with `lim login` or by setting `LIM_API_KEY`.
- Refer to `.agents/skills/limrun-xcode-bazel/SKILL.md` for the full `lim xcode
  rbe` workflow (bring up the remote stack, run the printed
  `bazelisk --digest_function=sha256 build --config=limrun //App:App`).
- Run `lim xcode rbe` from this directory (the Bazel workspace root); it writes
  `.limrun/` here.
