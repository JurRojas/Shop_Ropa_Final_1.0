# pedidos.py
"""
Rutas para gestión de pedidos.
"""
from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.pedido import Pedido, PedidoCreate, PedidoOut, DetallePedido, DetallePedidoCreate
from app.db.operaciones import cliente_existe, repartidor_existe, pedido_existe
from typing import List

router = APIRouter(prefix="/pedidos", tags=["Pedidos"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=PedidoOut)
def crear_pedido(pedido: PedidoCreate, db: Session = Depends(get_db)):
    """Crea un nuevo pedido para un cliente."""
    if not cliente_existe(db, pedido.cliente_id):
        raise HTTPException(status_code=404, detail="Cliente no existe")
    db_pedido = Pedido(cliente_id=pedido.cliente_id, estado="pendiente", total=pedido.total)
    db.add(db_pedido)
    db.commit()
    db.refresh(db_pedido)
    # Agregar detalles
    for det in pedido.detalles:
        db_det = DetallePedido(pedido_id=db_pedido.id, producto_id=det.producto_id, cantidad=det.cantidad)
        db.add(db_det)
    db.commit()
    return db_pedido

@router.get("/cliente/{id}", response_model=List[PedidoOut])
def pedidos_cliente(id: int, db: Session = Depends(get_db)):
    """Lista pedidos de un cliente."""
    return db.query(Pedido).filter(Pedido.cliente_id == id).all()

@router.get("/repartidor/{id}", response_model=List[PedidoOut])
def pedidos_repartidor(id: int, db: Session = Depends(get_db)):
    """Lista pedidos asignados a un repartidor."""
    return db.query(Pedido).filter(Pedido.repartidor_id == id).all()

@router.put("/{id}/estado")
def actualizar_estado(id: int, estado: str, db: Session = Depends(get_db)):
    """Actualiza el estado de un pedido (repartidor)."""
    pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no existe")
    pedido.estado = estado
    db.commit()
    return {"msg": "Estado actualizado"}

@router.put("/{id}/asignar")
def asignar_repartidor(id: int, repartidor_id: int, db: Session = Depends(get_db)):
    """Asigna un repartidor a un pedido (propietario)."""
    pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no existe")
    if pedido.repartidor_id:
        raise HTTPException(status_code=400, detail="Ya tiene repartidor asignado")
    if not repartidor_existe(db, repartidor_id):
        raise HTTPException(status_code=404, detail="Repartidor no existe")
    pedido.repartidor_id = repartidor_id
    db.commit()
    return {"msg": "Repartidor asignado"}

@router.get("/", response_model=List[PedidoOut])
def listar_pedidos(db: Session = Depends(get_db)):
    """Lista todos los pedidos (propietario)."""
    return db.query(Pedido).all()
