# dependencies.py
"""
Dependencias reutilizables para FastAPI.
"""
from app.db.database import SessionLocal

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
