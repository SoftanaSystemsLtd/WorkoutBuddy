# ProGuard/R8 rules for my_gym
# Keep Flutter classes
-keep class io.flutter.** { *; }
# Keep Dart generated plugin registrant
-keep class **GeneratedPluginRegistrant { *; }
# Add additional keep rules as needed for reflection or JSON parsing frameworks.
