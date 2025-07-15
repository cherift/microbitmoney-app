# Règles pour Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Supprimer les règles Play Core obsolètes et garder seulement:
-dontwarn com.google.android.play.core.**

# Règles pour éviter l'obfuscation des classes importantes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Règles pour AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Si vous utilisez des plugins spécifiques
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**