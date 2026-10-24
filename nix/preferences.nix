{ config, lib, ... }:

let
  user = lib.escapeShellArg config.system.primaryUser;
in
{
  # Existing explicit preferences captured on 2026-10-24. Unset options stay null.
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      minimize-to-application = true;
      wvous-br-corner = 14; # Quick Note
    };

    finder = {
      FXPreferredViewStyle = "Nlsv"; # List view
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
    };

    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      "com.apple.trackpad.scaling" = 2.0;
    };

    # These values are already set for both built-in and Bluetooth trackpads.
    trackpad = {
      Clicking = true;
      Dragging = false;
      DragLock = false;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadCornerSecondaryClick = 0;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRotate = true;
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    # These settings exist only for the built-in trackpad. The trackpad options
    # above also write Bluetooth preferences, so keep this device scope explicit.
    CustomUserPreferences."com.apple.AppleMultitouchTrackpad" = {
      ActuateDetents = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      ForceSuppressed = false;
    };
  };

  # Preserve the current-host scope of these existing tap/secondary-click values.
  # Ordinary NSGlobalDomain options would write the non-host-specific domain.
  system.activationScripts.userDefaults.text = lib.mkAfter ''
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  '';
}
