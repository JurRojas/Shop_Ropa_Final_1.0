# security.py
"""
Utilidades de seguridad para hash y verificación de contraseñas.
"""
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
try:
    from zoneinfo import ZoneInfo
except ImportError:
    from pytz import timezone as ZoneInfo
from fastapi import Request
from app.models.token_activo import TokenActivo
from sqlalchemy.orm import Session

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "supersecreto"  # Cambia esto por una clave segura
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 60

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def crear_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verificar_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise Exception("Token expirado")
    except jwt.InvalidTokenError:
        raise Exception("Token inválido")

def guardar_token_activo(db: Session, user_id: int, user_tipo: str, token: str, expira_en: datetime):
    zona_mx = ZoneInfo("America/Mexico_City")
    ahora = datetime.now(zona_mx)
    existente = db.query(TokenActivo).filter(TokenActivo.user_id == user_id, TokenActivo.user_tipo == user_tipo).first()
    if existente:
        existente.token = token
        existente.creado_en = ahora
        existente.expira_en = expira_en.astimezone(zona_mx)
    else:
        db.add(TokenActivo(user_id=user_id, user_tipo=user_tipo, token=token, creado_en=ahora, expira_en=expira_en.astimezone(zona_mx)))
    db.commit()

def token_activo_valido(db: Session, user_id: int, user_tipo: str, token: str) -> bool:
    t = db.query(TokenActivo).filter(TokenActivo.user_id == user_id, TokenActivo.user_tipo == user_tipo, TokenActivo.token == token).first()
    if not t:
        return False
    if t.expira_en < datetime.utcnow():
        db.delete(t)
        db.commit()
        return False
    return True

def eliminar_token(db: Session, token: str):
    db.query(TokenActivo).filter(TokenActivo.token == token).delete()
    db.commit()
