# repartidores.py
"""
Rutas para gestión de repartidores.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.models.repartidor import Repartidor, RepartidorCreate, RepartidorOut
from typing import List
from app.security import hash_password

router = APIRouter(prefix="/repartidores", tags=["Repartidores"])

@router.post("/", response_model=RepartidorOut)
def crear_repartidor(repartidor: RepartidorCreate, db: Session = Depends(get_db)):
    """Crea un nuevo repartidor."""
    if db.query(Repartidor).filter(Repartidor.email == repartidor.email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    hashed_password = hash_password(repartidor.contrasena)
    db_repartidor = Repartidor(nombre=repartidor.nombre, telefono=repartidor.telefono, email=repartidor.email, contrasena=hashed_password)
    db.add(db_repartidor)
    db.commit()
    db.refresh(db_repartidor)
    return db_repartidor

@router.get("/", response_model=List[RepartidorOut])
def listar_repartidores(db: Session = Depends(get_db)):
    """Lista todos los repartidores."""
    return db.query(Repartidor).all()
