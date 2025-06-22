# productos.py
"""
Rutas para gestión de productos.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Path
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.models.producto import Producto, ProductoCreate, ProductoOut
from typing import List

router = APIRouter(prefix="/productos", tags=["Productos"])

@router.get("/", response_model=List[ProductoOut])
def listar_productos(
    skip: int = Query(0, ge=0, description="Número de productos a omitir para paginación"),
    limit: int = Query(10, gt=0, le=100, description="Cantidad máxima de productos a retornar"),
    nombre: str = Query(None, min_length=2, max_length=100, description="Filtrar por nombre de producto"),
    db: Session = Depends(get_db)
):
    """Devuelve el catálogo de productos con filtros opcionales."""
    query = db.query(Producto)
    if nombre:
        query = query.filter(Producto.nombre.ilike(f"%{nombre}%"))
    return query.offset(skip).limit(limit).all()

@router.post("/", response_model=ProductoOut)
def crear_producto(producto: ProductoCreate, db: Session = Depends(get_db)):
    """Crea un nuevo producto. Valida campos en el body."""
    db_producto = Producto(**producto.dict())
    db.add(db_producto)
    db.commit()
    db.refresh(db_producto)
    return db_producto
