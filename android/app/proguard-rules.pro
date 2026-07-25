# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# MainActivity
-keep class ci.daoukro.user.** { *; }
-keep class ci.daoukro.daoukro_user.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter local notifications
-keep class com.dexterous.** { *; }

# Play Core (classes optionnelles utilisées par Flutter deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
