from sqlalchemy import Column, Integer, String
from app.core.database import Base

class Agent(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True)
    password_hash = Column(String(255))
    full_name = Column(String(100))
