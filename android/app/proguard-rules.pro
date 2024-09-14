# Mantenha as anotações essenciais
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }

# Evite minificação de classes do Tink
-dontwarn com.google.crypto.tink.**
-keep class com.google.crypto.tink.** { *; }
