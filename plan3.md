Wait, for protecting concurrent save/recovery operations:
If `restoreOperationalSnapshot` is a database transaction, SQLite prevents concurrent writes, but what if multiple Dart calls to `restoreOperationalSnapshot` happen?
Actually, the issue is that during `restoreOperationalSnapshot`, `Srs` and `bookmarks` lists could be large, and `await` is used extensively. What if a `putOperationalBookmark` or `gradeOperationalSrs` is called concurrently? `sqflite`'s `.transaction()` creates an exclusive lock on the database, so other operations on the same database will wait.
So, the DB is protected by `sqflite`. Wait, what does the requirement mean by "Protect concurrent save/recovery operations"?
Maybe it means preventing `KeyUnavailableException` writes when recovering?
Or maybe it means adding a Dart-level lock `bool _recoveryInProgress = false;` and throwing a `StateError` if a save operation occurs during it?
Or maybe protecting `_db` initialization?

"8. Protect concurrent save/recovery operations."
Let's see if there is already some concurrency issue.
`_migration` is cached:
```dart
  Future<LegacyProgressMigrationResult> migrateLegacyProgressDatabase() =>
      _migration ??= _migrateLegacyProgressDatabase().whenComplete(() {
        _migration = null;
      });
```
We could do the same for `restoreOperationalSnapshot`:
```dart
  Future<Map<String, int>>? _recoveryInProgress;

  Future<Map<String, int>> restoreOperationalSnapshot(...) {
    if (_recoveryInProgress != null) {
      throw StateError('A recovery operation is already in progress');
    }
    return _recoveryInProgress = _restoreOperationalSnapshot(...).whenComplete(() {
      _recoveryInProgress = null;
    });
  }
```
Wait, if it's protecting concurrent save/recovery, it means if I call `putRecord`, it should fail if recovery is in progress?
Or just preventing multiple recovery operations? "Protect concurrent save/recovery operations" -> concurrent save AND recovery operations.

Wait, the best way to protect both is a single `_activeOperation` Future, or just `_isRecovering` boolean.
Let's add `bool _isRecovering = false;`
Inside save operations (`putRecord`, `gradeOperationalSrs`, `incrementOperationalSrs`, `putOperationalBookmark`, `deleteOperationalBookmark`, `deleteRecord`, etc.), check:
```dart
    if (_isRecovering) throw StateError('Vault is currently locked for recovery');
```
Inside `restoreOperationalSnapshot`:
```dart
    if (_isRecovering) throw StateError('Vault is currently locked for recovery');
    _isRecovering = true;
    try {
      return await (await _db).transaction((txn) async { ... });
    } finally {
      _isRecovering = false;
    }
```
Wait, let's see how `StateError` is used.
Let's just use `_isRecovering = true` with `try...finally`.

Let's review the requirements:
"Validate ciphertext and record identity before accepting restored learner progress."
"Reject tampered records and invalid encryption envelopes."

When testing the code, if `KeyUnavailableException` is thrown, what is expected?
Let's update `AndroidKeystoreVaultCipher`:
```dart
  static Never _keyFailure(PlatformException error, StackTrace trace) {
    if (error.code == 'vault_key_unavailable_or_corrupt' ||
        error.code.toLowerCase().contains('keystore')) {
      UserVaultSecurityService.reportKeyFailure();
      throw KeyUnavailableException(error.message ?? 'Vault key unavailable');
    }
    Error.throwWithStackTrace(error, trace);
  }
```

In `UserVaultSecurityService.readRecord`:
```dart
    if (encrypted is! Uint8List ||
        encrypted.length < 29 ||
        (encrypted[0] != 1 && encrypted[0] != 2)) {
      throw CorruptRecordException('Vault record is corrupt');
    }
```

In `UserVaultSecurityService.putRecord`:
```dart
    if (ciphertext.length < 29 || (ciphertext[0] != 1 && ciphertext[0] != 2)) {
      throw CorruptRecordException('Invalid encrypted vault envelope');
    }
```

In `_writeEncrypted`:
```dart
    if (cipher.length < 29 || (cipher[0] != 1 && cipher[0] != 2)) {
      throw CorruptRecordException('Vault cipher returned an invalid envelope');
    }
```

In `_readEncryptedFrom`:
```dart
    if (encrypted is! Uint8List ||
        encrypted.length < 29 ||
        (encrypted[0] != 1 && encrypted[0] != 2)) {
      throw CorruptRecordException('Vault record is corrupt');
    }
```

In `exportOperationalSnapshot`:
```dart
          if (data['lexeme_id'] != id || data['target_language_code'] != lang) {
            throw TamperedRecordException('Vault SRS identity mismatch');
          }
```
```dart
            if (id is! String ||
                lang is! String ||
                _catalogKey(kind, id, lang) != key) {
              throw TamperedRecordException('Vault catalog identity mismatch');
            }
```

Also, how to prevent silent fallback to plaintext storage?
Wait, if it was possible to pass plaintext? No, the code already enforces encryption. The prompt says "Prevent silent fallback to plaintext storage." Where could it happen?
If `_cipher` is replaced? No, it's injected.
What if `get isOperationalActive` falls back?
"Do not silently regenerate a key" is already partially there in `_keyFailure`. But throwing `KeyUnavailableException` instead of regenerating.

Wait, in `AndroidKeystoreVaultCipher.encrypt`:
```dart
    if (UserVaultSecurityService._keyUnavailable) {
      throw KeyUnavailableException('Vault key recovery is required before further writes');
    }
```
Change `throw StateError('Vault key recovery is required before further writes')` to `throw KeyUnavailableException(...)`.

Let's do a search and replace.
