# login.py
"""
Endpoint de login para cliente, repartidor y administrador.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.cliente import Cliente
from app.models.repartidor import Repartidor
from app.models.administrador import Administrador
from pydantic import BaseModel
from passlib.context import CryptContext

router = APIRouter(prefix="/login", tags=["Login"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class LoginRequest(BaseModel):
    nombre: str
    contrasena: str

@router.post("/")
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    # Buscar en todas las tablas de usuario
    user = db.query(Cliente).filter(Cliente.nombre == datos.nombre).first()
    if user and pwd_context.verify(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como cliente", "tipo": "cliente", "id": user.id, "nombre": user.nombre}
    user = db.query(Repartidor).filter(Repartidor.nombre == datos.nombre).first()
    if user and pwd_context.verify(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como repartidor", "tipo": "repartidor", "id": user.id, "nombre": user.nombre}
    user = db.query(Administrador).filter(Administrador.nombre == datos.nombre).first()
    if user and pwd_context.verify(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como administrador", "tipo": "administrador", "id": user.id, "nombre": user.nombre}
    raise HTTPException(status_code=401, detail="Credenciales incorrectas")
