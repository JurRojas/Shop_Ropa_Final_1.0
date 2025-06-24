# dependencies.py
"""
Dependencias reutilizables para FastAPI.
"""
from fastapi import Header, HTTPException, Depends
from app.security import verificar_token, token_activo_valido
from app.models.token_activo import TokenActivo
from app.db.database import SessionLocal

def get_current_user(token: str = Header(..., alias="Authorization")):
    if token.startswith("Bearer "):
        token = token[7:]
    try:
        payload = verificar_token(token)
        db = SessionLocal()
        if not token_activo_valido(db, payload["user_id"], payload["user_tipo"], token):
            raise HTTPException(status_code=401, detail="Token inválido o expirado")
        return payload
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
