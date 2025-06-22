# clientes.py
"""
Rutas para gestión de clientes.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.models.cliente import Cliente, ClienteCreate, ClienteOut
from typing import List
from app.security import hash_password

router = APIRouter(prefix="/clientes", tags=["Clientes"])

@router.post("/", response_model=ClienteOut)
def crear_cliente(cliente: ClienteCreate, db: Session = Depends(get_db)):
    """Crea un nuevo cliente."""
    if db.query(Cliente).filter(Cliente.email == cliente.email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    hashed_password = hash_password(cliente.contrasena)
    db_cliente = Cliente(nombre=cliente.nombre, direccion=cliente.direccion, email=cliente.email, contrasena=hashed_password)
    db.add(db_cliente)
    db.commit()
    db.refresh(db_cliente)
    return db_cliente

@router.get("/", response_model=List[ClienteOut])
def listar_clientes(db: Session = Depends(get_db)):
    """Lista todos los clientes."""
    return db.query(Cliente).all()
