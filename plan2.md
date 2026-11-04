Let's see what needs to be changed in `lib/services/user_vault_security_service.dart`.
1. Update `StateError('Vault record is corrupt')` to throw `CorruptRecordException('Vault record is corrupt')`.
   - In `readRecord`: `throw CorruptRecordException('Vault record is corrupt');`
   - In `_readEncryptedFrom`: `throw CorruptRecordException('Vault record is corrupt');`
   - In `putRecord` envelope validation: `throw CorruptRecordException('Invalid encrypted vault envelope');`
   - In `_writeEncrypted` envelope validation: `throw CorruptRecordException('Vault cipher returned an invalid envelope');`
2. Update `StateError('Vault SRS identity mismatch')` etc. to `TamperedRecordException(...)`.
   - In `exportOperationalSnapshot`:
     - `throw TamperedRecordException('Vault SRS identity mismatch');`
     - `throw TamperedRecordException('Vault catalog identity mismatch');`
3. Update `AndroidKeystoreVaultCipher._keyFailure`:
   - Replace `Error.throwWithStackTrace(error, trace);` with throwing `KeyUnavailableException(error.message ?? 'Vault key unavailable')` if it's a key failure.
   - Wait, `_keyFailure` shouldn't just throw `PlatformException`.
     ```dart
       if (error.code == 'vault_key_unavailable_or_corrupt' ||
           error.code.toLowerCase().contains('keystore')) {
         UserVaultSecurityService.reportKeyFailure();
         throw KeyUnavailableException(error.message ?? 'Vault key unavailable');
       }
       Error.throwWithStackTrace(error, trace);
     ```
4. "Prevent silent fallback to plaintext storage."
   - Check if any method is falling back. In `UserVaultSecurityService`, the encryption is mandatory. But maybe in `_decodeProgress` if it's not encrypted? No, it returns `Map`.
5. "Protect concurrent save/recovery operations."
   - Add a Mutex or a boolean `_isRecovering` to prevent concurrent operations?
   - "concurrent save/recovery operations."
   - If `restoreOperationalSnapshot` is running, we shouldn't allow `putRecord`, `gradeOperationalSrs`, etc.
   - Wait, sqflite handles DB concurrency, but maybe there's a problem with `UserVaultSecurityService._keyUnavailable` state, or a Dart-level lock is needed because `restoreOperationalSnapshot` does a lot of awaits?
   - Let's introduce a `_operationLock` (or just an `_activeOperation` Future) for the whole vault, or specifically for recovery and writes. Wait, actually we can just use a simple `bool _isRecovering = false;` and throw `StateError('Vault is currently locked for recovery')`? Or a `Mutex` to await?
   Let's check how `sqflite` handles transactions. `db.transaction((txn) async { ... })` locks the database exclusively for the duration of the transaction. So SQLite handles the lock. Why does the requirement say "Protect concurrent save/recovery operations"?
   Maybe it's because `restoreOperationalSnapshot` doesn't protect against `isOperationalActive`?
   Wait! "Protect concurrent save/recovery operations."
   Look at `_keyUnavailable`. If key is unavailable, `putRecord` throws `StateError('Vault key recovery is required before further writes')`. But if recovery is happening concurrently?
   Let's add a `_syncLock` (Future) to serialize writes/recovery? Or just throw if recovery is active.

Let's check the test requirements:
"Add tests with injectable cryptographic adapters for tampering, wrong IDs, interrupted operations and recovery."
"Do not claim hardware-backed security is proven by Dart unit tests alone."

Let's look at `UserVaultSecurityService` again.
