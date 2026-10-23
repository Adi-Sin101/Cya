# LiteRT-LM JNI looks up InputData/response classes and members by name.
# The isolated minified probe crashed without these rules. Keep only the
# SDK wrapper package, leaving application shrinking/obfuscation enabled.
-keep class com.google.ai.edge.litertlm.** { *; }
