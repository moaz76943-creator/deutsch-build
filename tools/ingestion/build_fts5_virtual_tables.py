def build_fts5_tables(db):
    db.execute("CREATE VIRTUAL TABLE lexemes_fts USING fts5(sort_key, surface, content='lexemes', content_rowid='rowid')")
    db.execute("INSERT INTO lexemes_fts(rowid, sort_key, surface) SELECT rowid, sort_key, surface FROM lexemes")
    db.execute("CREATE VIRTUAL TABLE examples_fts USING fts5(sentence, translation_ar, content='examples', content_rowid='rowid')")
    db.execute("INSERT INTO examples_fts(rowid, sentence, translation_ar) SELECT rowid, sentence, translation_ar FROM examples")
