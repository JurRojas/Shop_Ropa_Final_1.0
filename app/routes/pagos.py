# pagos.py
"""
Rutas para simular pagos.
"""
from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models.pago import Pago, PagoCreate, PagoOut
from app.db.operaciones import pedido_existe
from typing import List

router = APIRouter(prefix="/pagos", tags=["Pagos"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

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
