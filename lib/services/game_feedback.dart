import 'dart:async';

import 'package:flutter/services.dart';

/// Synchronized sonic and tactile cues for the situation-room UI.
///
/// System sounds keep the app dependency- and asset-free while still giving
/// Android/iOS users immediate feedback. Unsupported platforms simply ignore
/// the platform calls; every cue is reinforced visually as well.
class GameFeedback {
  const GameFeedback._();

  static void navigate({required bool enabled}) {
    if (!enabled) return;
    unawaited(HapticFeedback.selectionClick());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void launch({required bool enabled}) {
    if (!enabled) return;
    unawaited(HapticFeedback.mediumImpact());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void scan({required bool enabled}) {
    if (!enabled) return;
    unawaited(HapticFeedback.lightImpact());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void decision({required bool enabled}) {
    if (!enabled) return;
    unawaited(HapticFeedback.mediumImpact());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void outcome({required bool enabled, required bool critical}) {
    if (!enabled) return;
    unawaited(
      critical ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact(),
    );
    unawaited(
      SystemSound.play(
        critical ? SystemSoundType.alert : SystemSoundType.click,
      ),
    );
  }

  static void toggle({required bool enabled}) {
    if (!enabled) return;
    unawaited(HapticFeedback.selectionClick());
    unawaited(SystemSound.play(SystemSoundType.click));
  }
}
