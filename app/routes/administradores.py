# administradores.py
"""
Rutas para gestión de administradores.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.models.administrador import Administrador, AdministradorCreate, AdministradorOut
from app.security import hash_password
from typing import List

router = APIRouter(prefix="/administradores", tags=["Administradores"])

@router.post("/", response_model=AdministradorOut)
def crear_administrador(admin: AdministradorCreate, db: Session = Depends(get_db)):
    """Crea un nuevo administrador."""
    if db.query(Administrador).filter(Administrador.email == admin.email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    hashed_password = hash_password(admin.contrasena)
    db_admin = Administrador(nombre=admin.nombre, email=admin.email, contrasena=hashed_password)
    db.add(db_admin)
    db.commit()
    db.refresh(db_admin)
    return db_admin

@router.get("/", response_model=List[AdministradorOut])
def listar_administradores(db: Session = Depends(get_db)):
    """Lista todos los administradores."""
    return db.query(Administrador).all()
