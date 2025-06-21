# productos.py
"""
Rutas para gestión de productos.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.producto import Producto, ProductoCreate, ProductoOut
from typing import List

router = APIRouter(prefix="/productos", tags=["Productos"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=List[ProductoOut])
def listar_productos(db: Session = Depends(get_db)):
    """Devuelve el catálogo de productos."""
    return db.query(Producto).all()

@router.post("/", response_model=ProductoOut)
def crear_producto(producto: ProductoCreate, db: Session = Depends(get_db)):
    """Crea un nuevo producto."""
    db_producto = Producto(**producto.dict())
    db.add(db_producto)
    db.commit()
    db.refresh(db_producto)
    return db_producto
