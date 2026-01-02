#!/usr/bin/env python3
import os
import sys
import sqlite3
import argparse
import fnmatch
import hashlib
import json
import time
from typing import List, Dict, Any, Optional

# --- Configuration ---
DB_NAME = "adbs_memory.db"
IGNORE_PATTERNS = [
    ".git*", "*.pyc", "__pycache__", "node_modules", "target", "build", 
    "dist", ".DS_Store", "*.db", "*.sqlite", "package-lock.json", ".adbs"
]
MAX_FILE_SIZE = 1024 * 1024  # 1MB limit for full file
CHUNK_SIZE = 1000            # Characters per chunk
CHUNK_OVERLAP = 200          # Overlap to preserve context

class TOonFormatter:
    """Simple Token-Oriented Object Notation formatter."""
    @staticmethod
    def dumps(data: Any) -> str:
        if isinstance(data, list) and data and isinstance(data[0], dict):
            # Optimizing list of dicts -> Table format
            # Identify columns
            keys = list(data[0].keys())
            lines = [" | ".join(keys)] # Header
            for item in data:
                values = []
                for k in keys:
                    val = str(item.get(k, "")).replace("\n", " ").replace("|", "¦")
                    # Truncate overly long values in TOon to save tokens further? 
                    # User wants optimized, but maybe not lossy. Let's keep it clean.
                    values.append(val)
                lines.append(" | ".join(values))
            return "\n".join(lines)
        elif isinstance(data, dict):
            # YAML-like
            lines = []
            for k, v in data.items():
                lines.append(f"{k}: {v}")
            return "\n".join(lines)
        else:
            return json.dumps(data) # Fallback

class MemoryEngine:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.has_vectors = False
        self._check_vector_support()
        self._init_db()

    def _check_vector_support(self):
        try:
            import numpy
            from sentence_transformers import SentenceTransformer
            # Use a smaller, faster model if possible, or standard MiniLM
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
            self.has_vectors = True
        except ImportError:
            pass

    def _init_db(self):
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        conn = sqlite3.connect(self.db_path)
        
        # Enable WAL for concurrency
        conn.execute("PRAGMA journal_mode=WAL;")
        # Enable Foreign Keys (Critical for ON DELETE CASCADE)
        conn.execute("PRAGMA foreign_keys = ON;")
        
        c = conn.cursor()
        
        # 1. Documents (File Metadata)
        c.execute('''CREATE TABLE IF NOT EXISTS documents (
            id TEXT PRIMARY KEY,
            path TEXT UNIQUE,
            checksum TEXT,
            last_indexed REAL
        )''')

        # 2. Chunks (Actual Content)
        # We split files into chunks for better retrieval
        c.execute('''CREATE TABLE IF NOT EXISTS chunks (
            id TEXT PRIMARY KEY,
            doc_id TEXT,
            chunk_index INTEGER,
            content TEXT,
            FOREIGN KEY(doc_id) REFERENCES documents(id) ON DELETE CASCADE
        )''')

        # 3. FTS (Search on Chunks)
        c.execute('''CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
            content,
            content='chunks'
        )''')

        # 4. Triggers for FTS
        c.execute('''CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
            INSERT INTO chunks_fts(rowid, content) VALUES (new.rowid, new.content);
        END;''')
        c.execute('''CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
        END;''')
        c.execute('''CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
            INSERT INTO chunks_fts(rowid, content) VALUES (new.rowid, new.content);
        END;''')

        # 5. Vectors (Optional)
        if self.has_vectors:
             c.execute('''CREATE TABLE IF NOT EXISTS chunk_vectors (
                chunk_id TEXT PRIMARY KEY,
                vector BLOB,
                FOREIGN KEY(chunk_id) REFERENCES chunks(id) ON DELETE CASCADE
            )''')

        conn.commit()
        conn.close()

    def sync(self, root_path: str):
        """Removes ghost files from DB that no longer exist in FS."""
        abs_root = os.path.abspath(root_path)
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Get all paths in DB
        c.execute("SELECT path FROM documents")
        db_paths = {row[0] for row in c.fetchall()}
        
        # Scan FS to validation (simplified check)
        # For a truly robust sync, we'd need to re-walk everything, but let's just check existence of DB entries.
        to_delete = []
        for path in db_paths:
            if not os.path.exists(path):
                to_delete.append(path)
            # handle rename? new file will be added by index, old file is just missing.
        
        if to_delete:
            print(f"Pruning {len(to_delete)} ghost files...")
            for path in to_delete:
                c.execute("DELETE FROM documents WHERE path=?", (path,))
            conn.commit()
        else:
            print("DB is in sync with filesystem.")
        
        conn.close()

    def index_path(self, path: str):
        abs_path = os.path.abspath(path)
        count = 0
        if os.path.isfile(abs_path):
             if self._index_file(abs_path): count+=1
        elif os.path.isdir(abs_path):
            print(f"Indexing directory: {abs_path}")
            for root, dirs, files in os.walk(abs_path):
                dirs[:] = [d for d in dirs if not self._is_ignored(d)]
                for file in files:
                    if self._is_ignored(file): continue
                    if self._index_file(os.path.join(root, file)):
                        count += 1
                        if count % 100 == 0: print(f"Indexed {count} files...")
        print(f"Indexing complete. Updated {count} documents.")

    def _is_ignored(self, name: str) -> bool:
        for pattern in IGNORE_PATTERNS:
            if fnmatch.fnmatch(name, pattern): return True
        return False

    def _chunk_text(self, text: str) -> List[str]:
        chunks = []
        start = 0
        text_len = len(text)
        
        while start < text_len:
            end = start + CHUNK_SIZE
            chunk = text[start:end]
            chunks.append(chunk)
            start += (CHUNK_SIZE - CHUNK_OVERLAP)
        
        return chunks

    def _index_file(self, filepath: str) -> bool:
        try:
            if os.path.getsize(filepath) > MAX_FILE_SIZE: return False
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                if '\x00' in content[:1024]: return False # Binary check
            
            checksum = hashlib.md5(content.encode('utf-8')).hexdigest()
            doc_id = hashlib.sha256(filepath.encode('utf-8')).hexdigest()

            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            # Check unmodified
            c.execute("SELECT checksum FROM documents WHERE id=?", (doc_id,))
            row = c.fetchone()
            if row and row[0] == checksum:
                conn.close()
                return False

            # Update Document
            c.execute("INSERT OR REPLACE INTO documents (id, path, checksum, last_indexed) VALUES (?, ?, ?, ?)",
                      (doc_id, filepath, checksum, time.time()))
            
            # Delete old chunks
            c.execute("DELETE FROM chunks WHERE doc_id=?", (doc_id,))
            
            # Create new chunks
            chunks = self._chunk_text(content)
            for i, chunk_text in enumerate(chunks):
                chunk_id = f"{doc_id}_{i}"
                c.execute("INSERT INTO chunks (id, doc_id, chunk_index, content) VALUES (?, ?, ?, ?)",
                          (chunk_id, doc_id, i, chunk_text))
                
                # Vectorize Chunk
                if self.has_vectors:
                    # We limit input length to avoid tokenizer errors/warnings
                    embedding = self.model.encode(chunk_text[:2000])
                    import numpy as np
                    blob = embedding.astype(np.float32).tobytes()
                    c.execute("INSERT INTO chunk_vectors (chunk_id, vector) VALUES (?, ?)", (chunk_id, blob))

            conn.commit()
            conn.close()
            return True

        except Exception as e:
            # print(f"Error indexing {filepath}: {e}")
            return False

    def query(self, query_text: str, limit: int = 5):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        c = conn.cursor()
        results = []

        # 1. Vector Search
        if self.has_vectors:
            try:
                import numpy as np
                query_vector = self.model.encode(query_text)
                
                c.execute("SELECT chunk_id, vector FROM chunk_vectors")
                rows = c.fetchall()
                scores = []
                for row in rows:
                    vec = np.frombuffer(row['vector'], dtype=np.float32)
                    score = np.dot(query_vector, vec) / (np.linalg.norm(query_vector) * np.linalg.norm(vec))
                    scores.append((row['chunk_id'], float(score)))
                
                scores.sort(key=lambda x: x[1], reverse=True)
                top_k = scores[:limit]
                
                for chunk_id, score in top_k:
                    c.execute("""
                        SELECT d.path, ch.content 
                        FROM chunks ch 
                        JOIN documents d ON ch.doc_id = d.id 
                        WHERE ch.id=?""", (chunk_id,))
                    row = c.fetchone()
                    if row:
                        results.append({
                            "type": "semantic",
                            "score": round(score, 3),
                            "path": row['path'],
                            "content": row['content'][:300].strip() + "..."
                        })
            except Exception:
                pass

        # 2. FTS Search
        if not results:
            safe_query = query_text.replace('"', '').replace("'", "")
            c.execute("""
                SELECT d.path, snippet(chunks_fts, 0, '[', ']', '...', 16) as snip
                FROM chunks_fts 
                JOIN chunks ch ON chunks_fts.rowid = ch.rowid
                JOIN documents d ON ch.doc_id = d.id
                WHERE chunks_fts MATCH ? 
                ORDER BY rank LIMIT ?""", (safe_query, limit))
            
            rows = c.fetchall()
            for row in rows:
                results.append({
                    "type": "keyword",
                    "score": 1.0,
                    "path": row['path'],
                    "content": row['snip']
                })

        conn.close()
        return results

def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command")
    
    # Common args
    parser.add_argument("--db", default=".adbs/internal/memory.db")
    
    # Commands
    p_idx = subparsers.add_parser("index")
    p_idx.add_argument("path")
    
    p_qry = subparsers.add_parser("query")
    p_qry.add_argument("text")
    p_qry.add_argument("--limit", type=int, default=5)
    
    p_sync = subparsers.add_parser("sync")
    p_sync.add_argument("path")

    args = parser.parse_args()
    
    # Resolve DB path
    db_path = os.path.abspath(args.db) if args.db.startswith(".") else args.db
    engine = MemoryEngine(db_path)

    if args.command == "index":
        engine.index_path(args.path)
    elif args.command == "sync":
        engine.sync(args.path)
    elif args.command == "query":
        results = engine.query(args.text, args.limit)
        print(TOonFormatter.dumps(results))
    else:
        parser.print_help()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Check environment variable for debugging
        if os.environ.get("ADBS_DEBUG"):
            raise
        # User-friendly error message
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
