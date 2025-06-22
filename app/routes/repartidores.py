# repartidores.py
"""
Rutas para gestión de repartidores.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.repartidor import Repartidor, RepartidorCreate, RepartidorOut
from typing import List
from passlib.context import CryptContext

router = APIRouter(prefix="/repartidores", tags=["Repartidores"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=RepartidorOut)
def crear_repartidor(repartidor: RepartidorCreate, db: Session = Depends(get_db)):
    """Crea un nuevo repartidor."""
    hashed_password = pwd_context.hash(repartidor.contrasena)
    db_repartidor = Repartidor(nombre=repartidor.nombre, telefono=repartidor.telefono, contrasena=hashed_password)
    db.add(db_repartidor)
    db.commit()
    db.refresh(db_repartidor)
    return db_repartidor

@router.get("/", response_model=List[RepartidorOut])
def listar_repartidores(db: Session = Depends(get_db)):
    """Lista todos los repartidores."""
    return db.query(Repartidor).all()
