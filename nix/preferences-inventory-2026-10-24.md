# macOS preferences migration

Completed **2026-10-24** on macOS **15.7.3**, using the pinned nix-darwin
**26.05** modules. The declaration is [preferences.nix](preferences.nix).
**Generation 10 is active.** The active system and selected profile match,
and the post-switch preference checks passed.

## Captured settings

Only existing, explicitly stored preferences are declared. The generated
activation writes **51 entries** across six scopes:

| Scope | Entries | Existing behavior preserved |
| --- | ---: | --- |
| Dock | 4 | Left edge, auto-hide, minimize into application icons, bottom-right Quick Note hot corner. |
| Finder | 4 | List view; show external and removable disks on the desktop; hide internal disks. |
| Global user preferences | 3 | Automatic capitalization and periods enabled; trackpad speed 2.0. |
| Built-in trackpad | 21 | Current tapping, dragging, secondary-click, gestures, haptic feedback, force click, and click-pressure settings. |
| Bluetooth trackpad | 17 | The existing shared gesture and click settings. |
| Current-host global preferences | 2 | Existing tap behavior and secondary-click enablement. |

The pinned `system.defaults.trackpad` options write both built-in and Bluetooth
domains. Four settings exist only for the built-in trackpad, so they use a
scoped `CustomUserPreferences` declaration. Two host-specific preferences use
an appended user-defaults activation script with `defaults -currentHost`.
Writing them to ordinary `NSGlobalDomain` would change their scope.

Boolean options normalize existing numeric 0/1 values to false/true while
preserving their meaning. Keyboard repeat, press-and-hold, Finder bars, file
extension display, and other unset settings remain undeclared. Dock app
arrangement and device metadata remain managed by macOS.

## Validation and backup

- The full nix-darwin build passed.
- Every generated preference write matches an existing snapshot key, value,
  and user/device/host scope. No previously absent key is introduced.
- The active generation's activation script contains the reviewed commands.
- All 51 values match live preferences after activation. An additional
  24 unmanaged settings retain their original values or absence.
- The active system and selected profile both resolve to generation 10.
  Homebrew Bundle reports all 40 declared dependencies installed, and Home
  Manager activation completed successfully.
- The generated defaults script and local activation helper pass shell syntax
  checks. Interactive behavior after activation has not yet been checked.

Six original preference-domain exports are saved outside the repository and
Nix store under:

```text
~/.local/state/nix-darwin/preferences-migration-20261024/
```

The directory is mode 0700 and the original plist backups are mode 0600.
The same directory contains the generated activation commands, managed-key
manifest, and verification results. The snapshots retain the original value
types for recovery. Removing a declaration or rolling back does not itself
delete previously written macOS preference keys.

## Activation and verification

The local `activate-and-verify.sh` helper completed the normal
`sudo darwin-rebuild switch` and verified the result. It checked the 51 managed
values, 24 unmanaged settings, expected activation commands, and agreement
between the active and selected system. No further switch is needed for this
migration. The successful log is:

```text
~/.local/state/nix-darwin/preferences-migration-20261024/switch-20261024-120236.log
```

`verification.json` in the same directory records the successful active-system
check. Dock restarts when nix-darwin applies the declared Dock preferences.

For a later read-only check of this snapshot:

```sh
python3 ~/.local/state/nix-darwin/preferences-migration-20261024/verify-preferences.py
```

After intentional preference changes, refresh the snapshot checks rather than
treating differences from this dated snapshot as migration failures.
