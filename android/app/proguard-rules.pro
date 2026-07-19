# home_widget pulls in androidx.glance:glance-appwidget, which transitively
# depends on WorkManager. WorkManager's default androidx.startup initializer
# (InitializationProvider) builds its internal Room database via reflection
# on androidx.work.impl.WorkDatabase_Impl before Application.onCreate runs.
# R8 has no static call site for that class and strips/renames pieces of it,
# so the reflective lookup fails with "Failed to create an instance of
# androidx.work.impl.WorkDatabase" and the app crashes on launch. Keep the
# generated database and worker constructors intact.
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.work.ListenableWorker {
    <init>(android.content.Context, androidx.work.WorkerParameters);
}
