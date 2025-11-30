from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import DB_CONNECTION_STRING

engine = create_engine(DB_CONNECTION_STRING)
SessionFactory = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionFactory()
    try:
        yield db
    finally:
        db.close()
