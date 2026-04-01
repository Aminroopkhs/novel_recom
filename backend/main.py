from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from database import Base, engine
from crud import load_books
from database import SessionLocal
from models import Book, User, Wishlist, Library
from recommender import (
    load_models_once,
    recommend_bert,
    recommend_e5,
    recommend_bge,
    compare_models
)
import random

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all (for now)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
Base.metadata.create_all(bind=engine)

@app.on_event("startup")
def warm_up_recommender_models():
    load_models_once()

@app.get("/")
def home():
    return {"msg": "DB Ready"}

@app.get("/load-data")
def load_data():
    load_books()
    return {"msg": "Data Loaded Successfully"}


@app.get("/books")
def get_books():
    db = SessionLocal()
    books = db.query(Book).limit(10).all()
    return [
        {
            "id": b.id,
            "title": b.title,
            "author": b.author,
            "genre": b.genre,
            "tropes": b.tropes,
            "imageUrl": b.imageUrl,
            "synopsis": b.synopsis,
            "rating": b.rating,
            "ratedBy": b.ratedBy,
        }
        for b in books
    ]

@app.post("/user")
def create_user(genre: str):
    db = SessionLocal()

    user = User(preferred_genre=genre)
    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "user_id": user.id,
        "preferred_genre": user.preferred_genre
    }

@app.post("/signup")
def signup(username: str, password: str):
    db = SessionLocal()

    existing = db.query(User).filter(User.username == username).first()
    if existing:
        return {"error": "User already exists"}

    user = User(username=username, password=password)
    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "msg": "User created",
        "user_id": user.id
    }

@app.post("/login")
def login(username: str, password: str):
    db = SessionLocal()

    user = db.query(User).filter(
        User.username == username,
        User.password == password
    ).first()

    if not user:
        return {"error": "Invalid credentials"}

    return {
        "user_id": user.id,
        "genre": user.preferred_genre
    }

@app.post("/set-genre/{user_id}")
def set_genre(user_id: int, genre: str):
    db = SessionLocal()

    user = db.query(User).filter(User.id == user_id).first()
    user.preferred_genre = genre

    db.commit()

    return {"msg": "Genre set"}


class UserPreferencesPayload(BaseModel):
    user_id: int
    genres: list[str]


@app.get("/user/preferences")
def get_user_preferences(user_id: int):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        return {"user_id": user_id, "genres": []}

    if user.preferred_genre:
        return {"user_id": user.id, "genres": [user.preferred_genre]}

    return {"user_id": user.id, "genres": []}


@app.post("/user/preferences")
def save_user_preferences(payload: UserPreferencesPayload):
    db = SessionLocal()
    user = db.query(User).filter(User.id == payload.user_id).first()

    if not user:
        return {"error": "User not found"}

    user.preferred_genre = payload.genres[0] if payload.genres else None
    db.commit()

    return {"msg": "Preferences updated", "genres": payload.genres}

@app.get("/user/{user_id}")
def get_user(user_id: int):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()

    return {
        "user_id": user.id,
        "genre": user.preferred_genre
    }

@app.get("/books/random")
def random_books():
    db = SessionLocal()
    books = db.query(Book).all()

    sample = random.sample(books, min(10, len(books)))

    return [
        {
            "id": b.id,
            "title": b.title,
            "image": b.imageUrl
        }
        for b in sample
    ]

@app.get("/book/{book_id}")
def book_details(book_id: int):
    db = SessionLocal()
    b = db.query(Book).filter(Book.id == book_id).first()

    return {
        "id": b.id,
        "title": b.title,
        "author": b.author,
        "genre": b.genre,
        "tropes": b.tropes,
        "synopsis": b.synopsis,
        "rating": b.rating,
        "image": b.imageUrl
    }

@app.post("/wishlist/{user_id}/{book_id}")
def add_wishlist(user_id: int, book_id: int):
    db = SessionLocal()

    item = Wishlist(user_id=user_id, book_id=book_id)
    db.add(item)
    db.commit()

    return {"msg": "Added to wishlist"}

@app.get("/wishlist/{user_id}")
def get_wishlist(user_id: int):
    db = SessionLocal()

    items = db.query(Wishlist).filter(Wishlist.user_id == user_id).all()

    books = []
    for item in items:
        b = db.query(Book).filter(Book.id == item.book_id).first()
        books.append({
                "id": b.id,
                "title": b.title,
                "author": b.author,
                "genre": b.genre,
                "tropes": b.tropes,
                "synopsis": b.synopsis,
                "image": None,   # 🔥 FIXED
                "rating": b.rating
        })

    return books

@app.post("/library/{user_id}/{book_id}")
def add_library(user_id: int, book_id: int):
    db = SessionLocal()

    item = Library(user_id=user_id, book_id=book_id)
    db.add(item)
    db.commit()

    return {"msg": "Added to library"}

@app.get("/library/{user_id}")
def get_library(user_id: int):
    db = SessionLocal()

    items = db.query(Library).filter(Library.user_id == user_id).all()

    books = []
    for item in items:
        b = db.query(Book).filter(Book.id == item.book_id).first()
        books.append({
                "id": b.id,
                "title": b.title,
                "author": b.author,
                "genre": b.genre,
                "tropes": b.tropes,
                "synopsis": b.synopsis,
                "image": b.imageUrl,   # 🔥 FIXED
                "rating": b.rating

        })

    return books

@app.get("/homepage/{user_id}")
def homepage(user_id: int):
    db = SessionLocal()

    user : User = db.query(User).filter(User.id == user_id).first()

    # ✅ RECOMMENDED (FULL DATA)
    rec_books = recommend_e5(user.preferred_genre)

    # ✅ GET ALL BOOKS
    books = db.query(Book).all()

    import random
    random.shuffle(books)

    random_books = books[:12]

    # 🔥 FORMAT FULL DATA
    def format_book(b):
        return {
            "id": b.id,
            "title": b.title,
            "author": b.author,
            "genre": b.genre,
            "tropes": b.tropes,
            "synopsis": b.synopsis,
            "image": b.imageUrl,
            "rating": b.rating
        }

    return {
        "genre": user.preferred_genre,
        "recommended": [format_book(b) for b in rec_books],
        "random": [format_book(b) for b in random_books]
    }

@app.get("/recommend/{genre}")
def recommend(genre: str):
    return {
        "bert": recommend_bert(genre),
        "e5": recommend_e5(genre),
        "bge": recommend_bge(genre)
    }
@app.delete("/wishlist/{user_id}/{book_id}")
def remove_wishlist(user_id: int, book_id: int):
    db = SessionLocal()

    item = db.query(Wishlist).filter(
        Wishlist.user_id == user_id,
        Wishlist.book_id == book_id
    ).first()

    if item:
        db.delete(item)
        db.commit()

    return {"msg": "Removed from wishlist"}

@app.delete("/library/{user_id}/{book_id}")
def remove_library(user_id: int, book_id: int):
    db = SessionLocal()

    item = db.query(Library).filter(
        Library.user_id == user_id,
        Library.book_id == book_id
    ).first()

    if item:
        db.delete(item)
        db.commit()

    return {"msg": "Removed from library"}

@app.get("/profile/{user_id}")
def get_profile(user_id: int):
    db = SessionLocal()

    user = db.query(User).filter(User.id == user_id).first()

    wishlist_count = db.query(Wishlist).filter(Wishlist.user_id == user_id).count()
    library_count = db.query(Library).filter(Library.user_id == user_id).count()

    return {
        "username": user.username,
        "genre": user.genre,
        "wishlist_count": wishlist_count,
        "library_count": library_count
    }

@app.get("/compare/{genre}")
def compare(genre: str):
    return compare_models(genre)

