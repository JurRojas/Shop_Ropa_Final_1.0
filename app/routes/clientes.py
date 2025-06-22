# clientes.py
"""
Rutas para gestión de clientes.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.cliente import Cliente, ClienteCreate, ClienteOut
from typing import List
from passlib.context import CryptContext

router = APIRouter(prefix="/clientes", tags=["Clientes"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=ClienteOut)
def crear_cliente(cliente: ClienteCreate, db: Session = Depends(get_db)):
    """Crea un nuevo cliente."""
    hashed_password = pwd_context.hash(cliente.contrasena)
    db_cliente = Cliente(nombre=cliente.nombre, direccion=cliente.direccion, contrasena=hashed_password)
    db.add(db_cliente)
    db.commit()
    db.refresh(db_cliente)
    return db_cliente

@router.get("/", response_model=List[ClienteOut])
def listar_clientes(db: Session = Depends(get_db)):
    """Lista todos los clientes."""
    return db.query(Cliente).all()
