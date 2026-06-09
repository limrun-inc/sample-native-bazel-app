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

## Cursor Cloud specific instructions

### Tooling

Global npm installs use `~/.npm-global` (system `/usr/lib/node_modules` is not
writable). Ensure `~/.npm-global/bin` is on `PATH` so `lim` and `bazelisk` are
found.

### RBE startup

1. Terminal 1 (keep running): `lim xcode rbe --ios` from the workspace root.
2. If startup fails with **"Instance … was not found"** right after creation,
   the sandbox may still be provisioning. Run `lim xcode list`, pick a `ready`
   instance, and retry: `lim xcode rbe --id <instance-id> --ios`.
3. Terminal 2: run the build command printed by the CLI, typically:
   `bazelisk --digest_function=sha256 build --config=limrun --remote_download_outputs=minimal //App:App`
4. Install on the attached simulator: `lim xcode rbe install` (not automatic
   after each build).
5. Teardown: `lim xcode rbe --stop`

### Simulator interaction

When `lim ios` commands report no recent instance, pass
`--id <ios-instance-id>` (printed when RBE attaches a simulator, or from
`lim ios list`).

Smoke-check the UI:

```bash
lim ios element-tree --id <ios-id> | grep "Hello, from Bazel"
lim ios screenshot screenshot.png --id <ios-id>
```

### Lint / tests

There are no in-repo lint configs or Bazel test targets. Verification is the
RBE build plus optional simulator UI checks above.
