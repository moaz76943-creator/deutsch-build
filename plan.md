1. **Refactor `build_sqlite_bytes` in `tools/language_pack_sqlite.py`:**
   - Extract schema creation logic into `_setup_schema(connection: sqlite3.Connection)`.
   - Extract metadata insertion into `_insert_metadata(connection: sqlite3.Connection, document: Mapping[str, Any], canonical_schema_version: int)`.
   - Extract localization insertion into `_insert_localization(connection: sqlite3.Connection, document: Mapping[str, Any])`.
   - Extract lexicon insertion into `_insert_lexicon(connection: sqlite3.Connection, document: Mapping[str, Any])`.
   - Extract concepts and forms insertion into `_insert_concepts(connection: sqlite3.Connection, document: Mapping[str, Any])`.
   - Extract word families insertion into `_insert_word_families(connection: sqlite3.Connection, document: Mapping[str, Any])`.
   - Extract grammar insertion into `_insert_grammar(connection: sqlite3.Connection, document: Mapping[str, Any])`.
2. **Update `build_sqlite_bytes`:**
   - Call the extracted functions inside `build_sqlite_bytes` to orchestrate them and simplify the method.
3. **Verify code:**
   - Use `read_file` or `cat` to check the updated file.
   - Run `python3 -m py_compile tools/language_pack_sqlite.py`.
4. **Run tests:**
   - Find relevant tests via `grep -rl build_sqlite_bytes tests/ tools/`.
   - Run the tests to ensure no functionality is broken.
5. Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
6. Submit the change.
