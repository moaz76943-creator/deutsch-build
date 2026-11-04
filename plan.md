1. **Understand Vault Exceptions:** The requirements ask to throw explicit exceptions for tampered records (`TamperedRecordException`), invalid encryption envelopes (`CorruptRecordException`), and key unavailability (`KeyUnavailableException`), and never silently recreate keys.
2. **Review `UserVaultSecurityService.dart`:**
   - In `AndroidKeystoreVaultCipher`, we must catch `PlatformException`s from the `MethodChannel` and appropriately mark `_keyUnavailable`. And we need to throw `KeyUnavailableException`.
   - In `UserVaultSecurityService.readRecord`, after decrypting, if the result is invalid, throw `CorruptRecordException`. But actually we might want to check the ciphertext itself *before* decryption for tampering, or check if the key fails. Wait, if the ciphertext length or header is invalid, we currently throw `StateError('Vault record is corrupt')`. Change this to `CorruptRecordException('Vault record is corrupt')`.
   - Wait, looking at `readRecord`:
     ```dart
     if (encrypted is! Uint8List ||
         encrypted.length < 29 ||
         (encrypted[0] != 1 && encrypted[0] != 2)) {
       throw StateError('Vault record is corrupt');
     }
     ```
     Change this `StateError` to `CorruptRecordException`.
   - Wait, the requirement says "Validate ciphertext and record identity before accepting restored learner progress. Reject tampered records and invalid encryption envelopes." So for `restoreOperationalSnapshot`, we might need to check if the ciphertext is valid, etc. Or maybe checking identity inside the `_decodeProgress`.
   - If a record is tampered with during recovery, we should throw `TamperedRecordException`. Wait, the requirement says "Reject tampered records and invalid encryption envelopes". Let's look at `UserVaultSecurityService.restoreOperationalSnapshot`. Currently it just accepts `incoming` data in plaintext. It does not validate ciphertext there. Wait, `restoreOperationalSnapshot` doesn't take ciphertext, it takes plaintext lists! Wait, no, maybe we need to validate when decrypting: the decrypted `identity` matches the expected `identity`. Let's check `_decodeProgress` and where we check identity.
   - Wait, `restoreOperationalSnapshot` takes `List<Map<String, Object?>> srs` and `bookmarks`. The ciphertext validation happens in `unsealArchiveChunk`? No, the requirement says "Validate ciphertext and record identity before accepting restored learner progress."
   - Ah, when reading `Srs` and `bookmarks`, if `id` doesn't match the `Srs` lexeme_id, we throw `StateError('Vault SRS identity mismatch')`. Maybe we should throw `TamperedRecordException`?
   - Let's check `exportOperationalSnapshot`:
     ```dart
         if (kind == 'srs') {
           if (data['lexeme_id'] != id || data['target_language_code'] != lang) {
             throw StateError('Vault SRS identity mismatch');
           }
     ```
     Change `StateError` to `TamperedRecordException`.

   Let's check the exceptions defined:
   ```dart
   class KeyUnavailableException extends VaultException {
     KeyUnavailableException(super.message);
   }

   class CorruptRecordException extends VaultException {
     CorruptRecordException(super.message);
   }

   class TamperedRecordException extends VaultException {
     TamperedRecordException(super.message);
   }
   ```

   Let's check `AndroidKeystoreVaultCipher`:
   ```dart
     static Never _keyFailure(PlatformException error, StackTrace trace) {
       if (error.code == 'vault_key_unavailable_or_corrupt' ||
           error.code.toLowerCase().contains('keystore')) {
         UserVaultSecurityService.reportKeyFailure();
         throw KeyUnavailableException(error.message ?? 'Vault key unavailable'); // Need to throw this
       }
       Error.throwWithStackTrace(error, trace);
     }
   ```
   Wait, if it was throwing `Error.throwWithStackTrace(error, trace)`, now we need to change it to throw `KeyUnavailableException`.

   Let's check "Prevent silent fallback to plaintext storage."
   "Prevent automatic replacement of unavailable keys."
   This is already partly in `_keyFailure`. "Do not silently regenerate a key". But we should throw `KeyUnavailableException`.

   Let's see the instructions again:
   7. Implement explicit key-unavailable and corrupt-record states.
   8. Protect concurrent save/recovery operations. (Maybe use a lock/mutex?)

   Let's examine the `UserVaultSecurityService` for concurrency.
   ```dart
   class UserVaultSecurityService {
      // ...
      Future<Database> get _db => _cached ??= _openDatabase();
      Future<LegacyProgressMigrationResult>? _migration;
   ```
   Wait, what if `restoreOperationalSnapshot` is called concurrently with `putOperationalBookmark`? `sqflite` transaction will serialize them, but maybe we need a Dart-level lock or we should check `restoreOperationalSnapshot` doesn't conflict?
   Actually, `sqflite` handles transactions. Is there a race condition in `isOperationalActive`?
   Wait, the requirement: "Protect concurrent save/recovery operations."
   Maybe we need to lock `restoreOperationalSnapshot` or `_migrateLegacyProgressDatabase`? `_migration ??= _migrateLegacyProgressDatabase().whenComplete(...)` protects migration. But what about recovery?

   Let's read `UserVaultSecurityService` carefully.
