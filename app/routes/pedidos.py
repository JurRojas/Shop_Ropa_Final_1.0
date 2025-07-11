# pedidos.py
"""
Rutas para gestión de pedidos.
"""
from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
from app.models.pedido import Pedido, PedidoCreate, PedidoOut, DetallePedido, DetallePedidoCreate
from app.db.operaciones import cliente_existe, repartidor_existe, pedido_existe
from typing import List

router = APIRouter(prefix="/pedidos", tags=["Pedidos"])

@router.post("/", response_model=PedidoOut)
def crear_pedido(pedido: PedidoCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    """Crea un nuevo pedido para un cliente. Valida body con Pydantic."""
    if user["user_tipo"] != "cliente" or user["user_id"] != pedido.cliente_id:
        raise HTTPException(status_code=403, detail="No autorizado para crear pedidos para otro usuario")
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
def pedidos_cliente(
    id: int = Path(..., gt=0, description="ID del cliente válido"),
    fecha_inicio: str = Query(None, description="Fecha de inicio en formato YYYY-MM-DD"),
    fecha_fin: str = Query(None, description="Fecha de fin en formato YYYY-MM-DD"),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    """Lista pedidos de un cliente, con filtros opcionales por fecha."""
    if user["user_tipo"] != "cliente" or user["user_id"] != id:
        raise HTTPException(status_code=403, detail="No autorizado para consultar pedidos de otro usuario")
    query = db.query(Pedido).filter(Pedido.cliente_id == id)
    # Filtros de fecha opcionales
    if fecha_inicio:
        query = query.filter(Pedido.fecha >= fecha_inicio)
    if fecha_fin:
        query = query.filter(Pedido.fecha <= fecha_fin)
    return query.all()

@router.get("/repartidor/{id}", response_model=List[PedidoOut])
def pedidos_repartidor(
    id: int = Path(..., gt=0, description="ID del repartidor válido"),
    estado: str = Query(None, regex="^(pendiente|recibido|en reparto|entregado)$", description="Filtrar por estado del pedido"),
    db: Session = Depends(get_db)
):
    """Lista pedidos asignados a un repartidor, con filtro opcional por estado."""
    query = db.query(Pedido).filter(Pedido.repartidor_id == id)
    if estado:
        query = query.filter(Pedido.estado == estado)
    return query.all()

@router.put("/{id}/estado")
def actualizar_estado(
    id: int = Path(..., gt=0, description="ID del pedido válido"),
    estado: str = Query(..., regex="^(pendiente|recibido|en reparto|entregado)$", description="Nuevo estado del pedido"),
    db: Session = Depends(get_db)
):
    """Actualiza el estado de un pedido (repartidor). Valida path y query."""
    pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no existe")
    pedido.estado = estado
    db.commit()
    return {"msg": "Estado actualizado"}

@router.put("/{id}/asignar")
def asignar_repartidor(
    id: int = Path(..., gt=0, description="ID del pedido válido"),
    repartidor_id: int = Query(..., gt=0, description="ID del repartidor válido"),
    db: Session = Depends(get_db)
):
    """Asigna un repartidor a un pedido (propietario). Valida path y query."""
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
def listar_pedidos(
    estado: str = Query(None, regex="^(pendiente|recibido|en reparto|entregado)$", description="Filtrar por estado de pedido"),
    db: Session = Depends(get_db)
):
    """Lista todos los pedidos (propietario), con filtro opcional por estado."""
    query = db.query(Pedido)
    if estado:
        query = query.filter(Pedido.estado == estado)
    return query.all()

@router.get("/{id}", response_model=PedidoOut)
def obtener_pedido(id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede consultar pedidos por id")
    pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return pedido

@router.put("/{id}", response_model=PedidoOut)
def actualizar_pedido(id: int, pedido: PedidoCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede modificar pedidos")
    db_pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not db_pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    db_pedido.cliente_id = pedido.cliente_id
    db_pedido.repartidor_id = pedido.repartidor_id
    db_pedido.estado = pedido.estado
    db_pedido.total = pedido.total
    db.commit()
    db.refresh(db_pedido)
    return db_pedido

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_pedido(id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede eliminar pedidos")
    pedido = db.query(Pedido).filter(Pedido.id == id).first()
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    db.delete(pedido)
    db.commit()
    return None
