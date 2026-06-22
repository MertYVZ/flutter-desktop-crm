# macOS build and DMG distribution

This project ships a Flutter macOS desktop app as a standard drag-to-Applications DMG.

## App metadata

| Setting | Value |
|--------|--------|
| Display name | Ok Teknik Metal CRM |
| Bundle ID | `com.okteknikmetal.okteknikmetalcrm` |
| Release `.app` path | `build/macos/Build/Products/Release/Ok Teknik Metal CRM.app` |
| Version source | `pubspec.yaml` (`version:` field) |

## Prerequisites

- macOS (Apple Silicon or Intel)
- [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) with macOS desktop enabled
- Xcode command-line tools: `xcode-select --install`

Optional (recommended for a polished DMG window):

```bash
brew install create-dmg
```

If `create-dmg` is not installed, the build script falls back to `hdiutil` (built into macOS).

## Build a DMG

From the repository root:

```bash
chmod +x scripts/build_macos_dmg.sh   # first time only
./scripts/build_macos_dmg.sh
```

This will:

1. Run `flutter build macos --release`
2. Package the Release `.app` into `dist/Ok_Teknik_Metal_CRM_<version>_macos.dmg`
3. Include an **Applications** folder shortcut for drag-and-drop install

### Options

```bash
# Re-package an existing Release build (skip Flutter compile)
./scripts/build_macos_dmg.sh --skip-build

# Ad-hoc sign before packaging (useful for local testing on other Macs)
./scripts/build_macos_dmg.sh --ad-hoc-sign
```

## Entitlements

Release builds use `macos/Runner/Release.entitlements`:

- App Sandbox enabled
- Outgoing network (client)
- User-selected file read/write

These are appropriate for a CRM app that talks to APIs and lets users pick/export files. Adjust entitlements in Xcode if you add capabilities (e.g. keychain, push, hardened runtime exceptions).

## Code signing and notarization

**Local / internal DMG (no Apple Developer account):**

- No signing is required to build or open the DMG on your own machine.
- Other users may see Gatekeeper warnings when opening an unsigned app.
- `--ad-hoc-sign` applies a local `-` identity so the app is at least signed for basic integrity checks; it does **not** satisfy Gatekeeper for wide distribution.

**Production distribution (recommended):**

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/).
2. Create a **Developer ID Application** certificate in Xcode or Apple Developer portal.
3. Sign the app before creating the DMG:

   ```bash
   export CODESIGN_IDENTITY="Developer ID Application: Your Company (TEAMID)"
   codesign --force --deep --sign "$CODESIGN_IDENTITY" --options runtime \
     "build/macos/Build/Products/Release/Ok Teknik Metal CRM.app"
   codesign --verify --deep --strict \
     "build/macos/Build/Products/Release/Ok Teknik Metal CRM.app"
   ./scripts/build_macos_dmg.sh --skip-build
   ```

4. **Notarize** the DMG (or the `.app` inside it) with `xcrun notarytool`, then staple:

   ```bash
   xcrun notarytool submit "dist/Ok_Teknik_Metal_CRM_1.0.0_macos.dmg" \
     --apple-id "you@example.com" \
     --team-id "TEAMID" \
     --password "app-specific-password" \
     --wait
   xcrun stapler staple "dist/Ok_Teknik_Metal_CRM_1.0.0_macos.dmg"
   ```

5. Optionally enable **Hardened Runtime** in Xcode (Runner target → Signing & Capabilities) for notarization compatibility.

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| `Release app not found` | Run `flutter build macos --release` or drop `--skip-build` |
| Gatekeeper blocks the app | Sign with Developer ID and notarize, or right-click → Open once |
| Sandbox file access errors | Ensure file pickers use user-selected URLs; extend entitlements only if needed |
| DMG layout looks plain | Install `create-dmg` via Homebrew and rebuild |

## Output layout

```
dist/
  Ok_Teknik_Metal_CRM_1.0.0_macos.dmg
```

The `dist/` directory is gitignored; distribute the DMG file directly to users.
