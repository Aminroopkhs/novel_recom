from fastapi import FastAPI
from database import Base, engine
from crud import load_books
from database import SessionLocal
from models import Book
from models import User
from models import Wishlist 
from models import Library
from recommender import (
    recommend_bert,
    recommend_e5,
    recommend_bge,
    compare_models
)
app = FastAPI()

Base.metadata.create_all(bind=engine)

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
            "title": b.title,
            "author": b.author,
            "genre": b.genre
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

@app.get("/user/{user_id}")
def get_user(user_id: int):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()

    return {
        "user_id": user.id,
        "genre": user.preferred_genre
    }

import random
from models import Book

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

from models import Wishlist

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
            "image": b.imageUrl
        })

    return books

from models import Library

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
            "image": b.imageUrl
        })

    return books

import random
from database import SessionLocal
from models import User, Book

@app.get("/homepage/{user_id}")
def homepage(user_id: int):
    db = SessionLocal()

    user = db.query(User).filter(User.id == user_id).first()

    # Random books
    books = db.query(Book).all()
    random_books = random.sample(books, min(10, len(books)))

    # E5 recommendations
    recommended = recommend_e5(user.preferred_genre)

    return {
        "genre": user.preferred_genre,
        "recommended": recommended,
        "random": [
            {
                "id": b.id,
                "title": b.title,
                "image": b.imageUrl
            }
            for b in random_books
        ]
    }

@app.get("/recommend/{genre}")
def recommend(genre: str):
    return {
        "bert": recommend_bert(genre),
        "e5": recommend_e5(genre),
        "bge": recommend_bge(genre)
    }

@app.get("/compare/{genre}")
def compare(genre: str):
    return compare_models(genre)

