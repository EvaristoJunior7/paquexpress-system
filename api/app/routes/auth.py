from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_token
from app.models.agent import Agent

router = APIRouter(tags=["Auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_user(data: dict, db: Session = Depends(get_db)):
    """Registrar nuevo agente"""
    try:
        # Verificar si el usuario ya existe
        existing_user = db.query(Agent).filter(
            Agent.username == data["username"]
        ).first()
        
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El nombre de usuario ya está registrado"
            )

        # Crear nuevo agente
        new_agent = Agent(
            username=data["username"],
            password_hash=hash_password(data["password"]),
            full_name=data["full_name"]
        )
        
        db.add(new_agent)
        db.commit()
        db.refresh(new_agent)
        
        return {
            "message": "Usuario registrado exitosamente",
            "user_id": new_agent.id,
            "username": new_agent.username
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en el registro: {str(e)}"
        )


@router.post("/token")
def login_user(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_db)
):
    """Iniciar sesión y obtener token"""
    try:
        user = db.query(Agent).filter(
            Agent.username == form_data.username
        ).first()
        
        if not user or not verify_password(form_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
                headers={"WWW-Authenticate": "Bearer"},
            )

        token = create_token({"sub": user.username})
        
        return {
            "access_token": token, 
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en el login: {str(e)}"
        )