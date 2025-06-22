# administradores.py
"""
Rutas para gestión de administradores.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.administrador import Administrador, AdministradorCreate, AdministradorOut
from passlib.context import CryptContext
from typing import List

router = APIRouter(prefix="/administradores", tags=["Administradores"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=AdministradorOut)
def crear_administrador(admin: AdministradorCreate, db: Session = Depends(get_db)):
    """Crea un nuevo administrador."""
    hashed_password = pwd_context.hash(admin.contrasena)
    db_admin = Administrador(nombre=admin.nombre, contrasena=hashed_password)
    db.add(db_admin)
    db.commit()
    db.refresh(db_admin)
    return db_admin

@router.get("/", response_model=List[AdministradorOut])
def listar_administradores(db: Session = Depends(get_db)):
    """Lista todos los administradores."""
    return db.query(Administrador).all()
