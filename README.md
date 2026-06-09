# Sample Native Bazel App

A minimal **Bazel** iOS app (`rules_apple` + `rules_swift`, bzlmod, Bazel 9) that
your coding agent can build from **any environment**, including Linux, using
Limrun's remote build execution (RBE). No local Xcode required.

It is deliberately tiny so the build is fast:

- `//App:App` - a single-module `ios_application` (SwiftUI "Hello, world!") with
  an asset catalog and a launch storyboard.

## Setup

Get an API key from the [Limrun Console](https://console.limrun.com):

```bash
export LIM_API_KEY=lim_....
```

Install the `lim` CLI:

```bash
npm install --global lim
```

The agent skill in `.agents/skills/limrun-xcode-bazel` documents the full `lim
xcode rbe` workflow.

## Build over Limrun RBE

From the workspace root, bring up the remote build stack:

```bash
lim xcode rbe
```

This targets/creates a remote Xcode instance, opens a tunnel, and writes a
`.limrun/` Bazel config. Keep it running. It prints the exact build command,
which on Bazel 9 is:

```bash
bazelisk --digest_function=sha256 build --config=limrun //App:App
```

Run that in another shell. Apple build actions (Swift compile, asset catalog,
storyboard, bundling) execute on the remote Mac worker. Stop the stack with
`lim xcode rbe --stop`.

> Bazel 9 defaults to the BLAKE3 digest; the Limrun cache currently requires
> SHA256, so `--digest_function=sha256` must come **before** `build` (it is a
> startup flag). Use the command the CLI prints verbatim.

## Local build (optional, macOS with Xcode)

If you are on a Mac with Xcode and just want a simulator `.app`:

```bash
bazelisk build //App:App
```

The built bundle lands under
`bazel-bin/App/App.app`. Archive and push it to Limrun Asset Storage to get
simulators with the app pre-installed:

```bash
tar -czf sample-native-bazel-app.app.tar.gz -C bazel-bin/App App.app
lim push sample-native-bazel-app.app.tar.gz
lim run ios --install-asset=sample-native-bazel-app.app.tar.gz
```
