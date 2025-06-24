# repartidores.py
"""
Rutas para gestión de repartidores.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
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
def listar_repartidores(db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Lista todos los repartidores."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede consultar repartidores")
    return db.query(Repartidor).all()

@router.get("/{repartidor_id}", response_model=RepartidorOut)
def obtener_repartidor(repartidor_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Obtener un repartidor por ID."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede consultar repartidores")
    repartidor = db.query(Repartidor).filter(Repartidor.id == repartidor_id).first()
    if not repartidor:
        raise HTTPException(status_code=404, detail="Repartidor no encontrado")
    return repartidor

@router.put("/{repartidor_id}", response_model=RepartidorOut)
def actualizar_repartidor(repartidor_id: int, repartidor: RepartidorCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Actualizar datos de un repartidor."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede modificar repartidores")
    db_repartidor = db.query(Repartidor).filter(Repartidor.id == repartidor_id).first()
    if not db_repartidor:
        raise HTTPException(status_code=404, detail="Repartidor no encontrado")
    db_repartidor.nombre = repartidor.nombre
    db_repartidor.telefono = repartidor.telefono
    db_repartidor.email = repartidor.email
    db_repartidor.contrasena = hash_password(repartidor.contrasena)
    db.commit()
    db.refresh(db_repartidor)
    return db_repartidor

@router.delete("/{repartidor_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_repartidor(repartidor_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Eliminar un repartidor por ID."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede eliminar repartidores")
    repartidor = db.query(Repartidor).filter(Repartidor.id == repartidor_id).first()
    if not repartidor:
        raise HTTPException(status_code=404, detail="Repartidor no encontrado")
    db.delete(repartidor)
    db.commit()
    return None
