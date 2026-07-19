import 'package:flutter/material.dart';

/// Parses an [Event.color] string ("0xFF2196F3") into a [Color], falling
/// back to a sensible default for malformed values. Kept separate from the
/// (material-free) models so the color format lives in one place.
Color parseEventColor(String value) {
  final hex = value.toLowerCase().startsWith('0x') ? value.substring(2) : value;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? const Color(0xFF2196F3) : Color(parsed);
}

/// The preset palette offered in the event editor.
const List<int> kEventColorPalette = [
  0xFF2196F3, // blue
  0xFF4CAF50, // green
  0xFFF44336, // red
  0xFFFF9800, // orange
  0xFF9C27B0, // purple
  0xFF009688, // teal
  0xFF607D8B, // blue grey
];
