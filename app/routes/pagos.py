# pagos.py
"""
Rutas para simular pagos.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Form
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
from app.models.pago import Pago, PagoCreate, PagoOut
from app.models.tarjeta import Tarjeta
from app.models.pedido import Pedido
from app.db.operaciones import pedido_existe
from typing import List

router = APIRouter(prefix="/pagos", tags=["Pagos"])

@router.post("/", response_model=PagoOut)
def simular_pago(pago: PagoCreate, db: Session = Depends(get_db)):
    """Simula un pago para un pedido. Valida body con Pydantic."""
    if not pedido_existe(db, pago.pedido_id):
        raise HTTPException(status_code=404, detail="Pedido no existe")
    db_pago = Pago(pedido_id=pago.pedido_id)
    db.add(db_pago)
    db.commit()
    db.refresh(db_pago)
    return db_pago

@router.get("/", response_model=List[PagoOut])
def listar_pagos(db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede listar pagos")
    return db.query(Pago).all()

@router.get("/{id}", response_model=PagoOut)
def obtener_pago(id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede consultar pagos")
    pago = db.query(Pago).filter(Pago.id == id).first()
    if not pago:
        raise HTTPException(status_code=404, detail="Pago no encontrado")
    return pago

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_pago(id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede eliminar pagos")
    pago = db.query(Pago).filter(Pago.id == id).first()
    if not pago:
        raise HTTPException(status_code=404, detail="Pago no encontrado")
    db.delete(pago)
    db.commit()
    return None

@router.post("/tarjetas/", response_model=dict)
def registrar_tarjeta(
    cliente_id: int = Form(...),
    numero: str = Form(...),
    nombre: str = Form(...),
    vencimiento: str = Form(...),
    cvv: str = Form(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    if user["user_tipo"] != "cliente" or user["user_id"] != cliente_id:
        raise HTTPException(status_code=403, detail="No autorizado para registrar tarjeta")
    tarjeta = Tarjeta(
        cliente_id=cliente_id,
        numero=numero,
        nombre=nombre,
        vencimiento=vencimiento,
        cvv=cvv
    )
    db.add(tarjeta)
    db.commit()
    db.refresh(tarjeta)
    return {"msg": "Tarjeta registrada", "id": tarjeta.id}

@router.get("/tarjetas/{cliente_id}", response_model=list)
def listar_tarjetas(cliente_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    if user["user_tipo"] != "cliente" or user["user_id"] != cliente_id:
        raise HTTPException(status_code=403, detail="No autorizado para ver tarjetas")
    tarjetas = db.query(Tarjeta).filter(Tarjeta.cliente_id == cliente_id).all()
    return [{"id": t.id, "numero": t.numero, "nombre": t.nombre, "vencimiento": t.vencimiento} for t in tarjetas]

@router.post("/{pedido_id}", response_model=PagoOut)
def pagar_con_tarjeta(
    pedido_id: int,
    tarjeta_id: int = Form(None),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    if not pedido_existe(db, pedido_id):
        raise HTTPException(status_code=404, detail="Pedido no existe")
    # Validar que la tarjeta pertenezca al usuario
    if tarjeta_id is not None:
        tarjeta = db.query(Tarjeta).filter(Tarjeta.id == tarjeta_id).first()
        if not tarjeta or tarjeta.cliente_id != user["user_id"]:
            raise HTTPException(status_code=403, detail="Tarjeta no válida para este usuario")
    # Registrar el pago
    db_pago = Pago(pedido_id=pedido_id, tarjeta_id=tarjeta_id)
    db.add(db_pago)
    # Cambiar estado del pedido a 'pagado'
    pedido = db.query(Pedido).filter(Pedido.id == pedido_id).first()
    if pedido:
        pedido.estado = "pagado"
    db.commit()
    db.refresh(db_pago)
    return db_pago
