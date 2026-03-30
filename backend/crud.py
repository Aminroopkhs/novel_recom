import pandas as pd
from database import SessionLocal
from models import Book

def load_books():
    db = SessionLocal()

    # Adjust path if needed
    df = pd.read_csv("data/novel.csv")

    print("Columns:", df.columns)

    for _, row in df.iterrows():
        try:
            book = Book(
                title=str(row.get("title", "")),
                author=str(row.get("author", "")),
                genre=str(row.get("genre", "")),
                tropes=str(row.get("tropes", "")),
                imageUrl=str(row.get("imageUrl", "")),
                synopsis=str(row.get("synopsis", "")),
                rating=float(row.get("rating", 0)),
                ratedBy=int(str(row.get("ratedBy", "0")).strip())  # SAFE FIX
            )
            db.add(book)
        except Exception as e:
            print("Error in row:", row)
            print(e)

    db.commit()
    db.close()

    print("✅ Data Loaded Successfully")