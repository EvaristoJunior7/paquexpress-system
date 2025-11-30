from datetime import datetime, timedelta
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from passlib.context import CryptContext
import jwt

from app.core.config import JWT_SECRET, ENCRYPTION_ALGO, TOKEN_DURATION_MINUTES
from app.models.agent import Agent
from app.core.database import get_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth = OAuth2PasswordBearer(tokenUrl="token")


def hash_password(pwd: str):
    return pwd_context.hash(pwd)

def verify_password(pwd: str, hashed: str):
    return pwd_context.verify(pwd, hashed)


def create_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=TOKEN_DURATION_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET, ENCRYPTION_ALGO)


def get_current_agent(token: str = Depends(oauth), db: Session = Depends(get_db)):
    cred_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[ENCRYPTION_ALGO])
        username = payload.get("sub")
        if username is None:
            raise cred_error
    except:
        raise cred_error

    agent = db.query(Agent).filter(Agent.username == username).first()
    if not agent:
        raise cred_error

    return agent
