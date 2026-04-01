from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from database import SessionLocal
from models import Book
import time
from threading import Lock

# -----------------------------
# MODEL REGISTRY (LAZY + SAFE)
# -----------------------------
bert_model = None
e5_model = None
bge_model = None
_models_lock = Lock()


def load_models_once():
    """Load sentence-transformer models once per process."""
    global bert_model, e5_model, bge_model

    if bert_model is not None and e5_model is not None and bge_model is not None:
        return

    with _models_lock:
        if bert_model is not None and e5_model is not None and bge_model is not None:
            return

        print("Loading recommendation models...")
        bert_model = SentenceTransformer('all-MiniLM-L6-v2')
        e5_model = SentenceTransformer('intfloat/e5-small')
        bge_model = SentenceTransformer('BAAI/bge-small-en')
        print("Recommendation models ready.")


# -----------------------------
# WEIGHTED TEXT FUNCTION
# -----------------------------
def build_weighted_text(book):
    return (
        (book.genre + " ") * 3 +      # HIGH weight
        (book.tropes + " ") * 2 +     # MEDIUM weight
        (book.synopsis + " ") * 1     # LOW weight
    )


# -----------------------------
# GENERIC RECOMMENDER
# -----------------------------
def recommend_books(model, user_genre):
    db = SessionLocal()
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

    return [b for b, _ in ranked[:10]]


# -----------------------------
# MODEL-SPECIFIC FUNCTIONS
# -----------------------------
def recommend_bert(user_genre):
    load_models_once()
    return recommend_books(bert_model, user_genre)


def recommend_e5(user_genre):
    load_models_once()
    return recommend_books(e5_model, user_genre)


def recommend_bge(user_genre):
    load_models_once()
    return recommend_books(bge_model, user_genre)


# -----------------------------
# MODEL COMPARISON
# -----------------------------
def compare_models(user_genre):
    load_models_once()
    results = {}

    models = {
        "BERT": bert_model,
        "E5": e5_model,
        "BGE": bge_model
    }

    for name, model in models.items():
        start = time.time()

        recs = recommend_books(model, user_genre)

        end = time.time()

        avg_score = sum([r["score"] for r in recs]) / len(recs)

        results[name] = {
            "time_taken": round(end - start, 3),
            "avg_score": round(avg_score, 3),
            "top_result": recs[0]["title"]
        }

    return results