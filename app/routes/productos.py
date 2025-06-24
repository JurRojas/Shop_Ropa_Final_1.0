# productos.py
"""
Rutas para gestión de productos.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Path, status
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
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

@router.delete("/{id}", response_model=dict)
def eliminar_producto(id: int = Path(..., gt=0), db: Session = Depends(get_db)):
    """Elimina un producto existente por ID."""
    producto = db.query(Producto).filter(Producto.id == id).first()
    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    db.delete(producto)
    db.commit()
    return {"msg": "Producto eliminado"}

@router.get("/{id}", response_model=ProductoOut)
def obtener_producto(id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Obtiene un producto por su ID."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede consultar productos por id")
    producto = db.query(Producto).filter(Producto.id == id).first()
    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return producto

@router.put("/{id}", response_model=ProductoOut)
def actualizar_producto(id: int, producto: ProductoCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Actualiza un producto existente por ID."""
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede modificar productos")
    db_producto = db.query(Producto).filter(Producto.id == id).first()
    if not db_producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    for key, value in producto.dict().items():
        setattr(db_producto, key, value)
    db.commit()
    db.refresh(db_producto)
    return db_producto
