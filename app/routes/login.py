# login.py
"""
Endpoint de login para cliente, repartidor y administrador.
"""
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
from app.models.cliente import Cliente
from app.models.repartidor import Repartidor
from app.models.administrador import Administrador
from pydantic import BaseModel
from app.security import verify_password, crear_token, guardar_token_activo, eliminar_token
from datetime import datetime, timedelta

router = APIRouter(prefix="/login", tags=["Login"])

class LoginRequest(BaseModel):
    email: str
    contrasena: str

@router.post("/")
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    # Buscar en todas las tablas de usuario por email
    user = db.query(Cliente).filter(Cliente.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        # Generar token y guardar
        token = crear_token({"user_id": user.id, "user_tipo": "cliente"})
        expira_en = datetime.utcnow() + timedelta(minutes=60)
        guardar_token_activo(db, user.id, "cliente", token, expira_en)
        return {"msg": "Login exitoso como cliente", "tipo": "cliente", "id": user.id, "nombre": user.nombre, "token": token}
    user = db.query(Repartidor).filter(Repartidor.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        token = crear_token({"user_id": user.id, "user_tipo": "repartidor"})
        expira_en = datetime.utcnow() + timedelta(minutes=60)
        guardar_token_activo(db, user.id, "repartidor", token, expira_en)
        return {"msg": "Login exitoso como repartidor", "tipo": "repartidor", "id": user.id, "nombre": user.nombre, "token": token}
    user = db.query(Administrador).filter(Administrador.email == datos.email).first()
    if user and verify_password(datos.contrasena, user.contrasena):
        token = crear_token({"user_id": user.id, "user_tipo": "administrador"})
        expira_en = datetime.utcnow() + timedelta(minutes=60)
        guardar_token_activo(db, user.id, "administrador", token, expira_en)
        return {"msg": "Login exitoso como administrador", "tipo": "administrador", "id": user.id, "nombre": user.nombre, "token": token}
    raise HTTPException(status_code=401, detail="Credenciales incorrectas")

@router.post("/logout")
def logout(token: str = Header(..., alias="Authorization"), db: Session = Depends(get_db)):
    if token.startswith("Bearer "):
        token = token[7:]
    eliminar_token(db, token)
    return {"msg": "Logout exitoso"}

@router.get("/protegido")
def endpoint_protegido(user=Depends(get_current_user)):
    return {"msg": f"Acceso permitido para usuario {user['user_id']} ({user['user_tipo']})"}
