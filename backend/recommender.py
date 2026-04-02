from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from database import SessionLocal
from models import Book
import joblib
import scipy.sparse
import time
from pathlib import Path
import sys

class EnsembleRecommender:
    def __init__(self, tfidf, tfidf_matrix, knn, df):
        self.tfidf = tfidf
        self.tfidf_matrix = tfidf_matrix
        self.knn = knn
        self.df = df

    def _cosine_rank(self, q_vec, top_n=50):
        sim = cosine_similarity(q_vec, self.tfidf_matrix)[0]
        return sim.argsort()[::-1][:top_n]

    def _knn_rank(self, query, top_n=50):
        # Use KNN pipeline's own tfidf — NOT the standalone one
        q_vec = self.knn.named_steps['tfidf'].transform([query])
        _, indices = self.knn.named_steps['knn'].kneighbors(q_vec, n_neighbors=top_n)
        return indices[0]

    def _rrf(self, *rank_lists, k=60):
        scores = {}
        for rank_list in rank_lists:
            for rank, idx in enumerate(rank_list):
                scores[idx] = scores.get(idx, 0) + 1 / (k + rank + 1)
        return [idx for idx, _ in sorted(scores.items(), key=lambda x: x[1], reverse=True)]

    def recommend(self, query, top_n=5):
        q_vec = self.tfidf.transform([query])

        cos  = self._cosine_rank(q_vec)
        knn  = self._knn_rank(query)       # passes raw query string
        fused = self._rrf(cos, knn)

        sort_col = 'weighted_rating' if 'weighted_rating' in self.df.columns else 'rating'
        selected_cols = [
            col for col in ['id', 'title', 'author', 'genre', 'rating']
            if col in self.df.columns
        ]

        return (
            self.df.iloc[fused]
            .sort_values(by=sort_col, ascending=False)
            .head(top_n)[selected_cols]
        )

# Uvicorn reload uses multiprocessing and may look for classes on __mp_main__.
mp_main = sys.modules.get("__mp_main__")
if mp_main is not None and not hasattr(mp_main, "EnsembleRecommender"):
    setattr(mp_main, "EnsembleRecommender", EnsembleRecommender)

# -----------------------------
# LOAD MODELS (GLOBAL)
# -----------------------------
print("🔄 Loading models...")

DATA_DIR = Path(__file__).resolve().parent / "data"

ensemble = joblib.load(DATA_DIR / "ensemble_recommender.pkl")
ensemble.tfidf_matrix = scipy.sparse.load_npz(DATA_DIR / "tfidf_matrix.npz")
bert_model = SentenceTransformer('all-MiniLM-L6-v2')   # BERT-like
e5_model = SentenceTransformer('intfloat/e5-small')    # E5
bge_model = SentenceTransformer('BAAI/bge-small-en')   # BGE

print("✅ Models loaded!")


# -----------------------------
# WEIGHTED TEXT FUNCTION
# -----------------------------
def build_weighted_text(book):
    return (
        (book.genre + " ") * 3 +      # HIGH weight
        (book.tropes + " ") * 2 +     # MEDIUM weight
        (book.synopsis + " ") * 1     # LOW weight
    )


def _rank_books(model, user_genre, top_n=10):
    db = SessionLocal()
    try:
        books = db.query(Book).all()

        texts = [build_weighted_text(b) for b in books]

        # Encode all books
        embeddings = model.encode(texts)

        # Encode user query
        query_embedding = model.encode([user_genre])

        # Compute similarity
        scores = cosine_similarity(query_embedding, embeddings)[0]

        # Rank results
        ranked = sorted(zip(books, scores), key=lambda x: x[1], reverse=True)
        return ranked[:top_n]
    finally:
        db.close()


# -----------------------------
# GENERIC RECOMMENDER
# -----------------------------
def recommend_books(model, user_genre):
    return [book for book, _ in _rank_books(model, user_genre, top_n=10)]


# -----------------------------
# MODEL-SPECIFIC FUNCTIONS
# -----------------------------
def recommend_bert(user_genre):
    return recommend_books(bert_model, user_genre)


def recommend_e5(user_genre):
    return recommend_books(e5_model, user_genre)


def recommend_bge(user_genre):
    return recommend_books(bge_model, user_genre)

def recommend_ml(user_genre):
    ranked_rows = ensemble.recommend(user_genre, top_n=10)

    def make_key(title, author, genre):
        return (
            str(title).strip().lower(),
            str(author).strip().lower(),
            str(genre).strip().lower(),
        )

    db = SessionLocal()
    try:
        books = db.query(Book).all()
        books_by_key = {}

        for book in books:
            books_by_key.setdefault(make_key(book.title, book.author, book.genre), book)

        recommended = []
        seen_ids = set()

        for row in ranked_rows.to_dict(orient="records"):
            key = make_key(row.get("title"), row.get("author"), row.get("genre"))
            book = books_by_key.get(key)

            if book is not None and book.id not in seen_ids:
                recommended.append(book)
                seen_ids.add(book.id)

        return recommended
    finally:
        db.close()

# -----------------------------
# MODEL COMPARISON
# -----------------------------
def compare_models(user_genre):
    results = {}

    models = {
        "BERT": bert_model,
        "E5": e5_model,
        "BGE": bge_model
    }

    for name, model in models.items():
        start = time.time()

        ranked = _rank_books(model, user_genre)
        recs = [book for book, _ in ranked]

        end = time.time()

        avg_score = sum(score for _, score in ranked) / len(ranked) if ranked else 0.0

        results[name] = {
            "time_taken": round(end - start, 3),
            "avg_score": round(avg_score, 3),
            "top_result": recs[0].title if recs else None
        }

    return results