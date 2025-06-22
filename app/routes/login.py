# login.py
"""
Endpoint de login para cliente, repartidor y administrador.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.models.cliente import Cliente
from app.models.repartidor import Repartidor
from app.models.administrador import Administrador
from pydantic import BaseModel
from app.security import verify_password

router = APIRouter(prefix="/login", tags=["Login"])

class LoginRequest(BaseModel):
    email: str
    contrasena: str

@router.post("/")
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    # Buscar en todas las tablas de usuario por email
    user = db.query(Cliente).filter(Cliente.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como cliente", "tipo": "cliente", "id": user.id, "nombre": user.nombre}
    user = db.query(Repartidor).filter(Repartidor.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como repartidor", "tipo": "repartidor", "id": user.id, "nombre": user.nombre}
    user = db.query(Administrador).filter(Administrador.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        return {"msg": "Login exitoso como administrador", "tipo": "administrador", "id": user.id, "nombre": user.nombre}
    raise HTTPException(status_code=401, detail="Credenciales incorrectas")
