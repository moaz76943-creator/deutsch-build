class ApkPermissionMinimalistPruner {
  final List<String> allowedPermissions = ['RECORD_AUDIO', 'MODIFY_AUDIO_SETTINGS'];
  bool isRestricted(String perm) => !allowedPermissions.contains(perm);
}
