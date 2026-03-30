from sqlalchemy import Column, Integer, String, Float, Text
from database import Base

class Book(Base):
    __tablename__ = "books"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    author = Column(String)
    genre = Column(String)
    tropes = Column(Text)
    imageUrl = Column(String)
    synopsis = Column(Text)
    rating = Column(Float)
    ratedBy = Column(Integer)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    password = Column(String)
    preferred_genre = Column(String, nullable=True)


class Wishlist(Base):
    __tablename__ = "wishlist"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    book_id = Column(Integer)


class Library(Base):
    __tablename__ = "library"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    book_id = Column(Integer)