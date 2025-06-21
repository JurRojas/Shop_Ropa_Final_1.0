# pago.py
"""
Modelo SQLAlchemy y esquema Pydantic para pagos simulados.
"""
from sqlalchemy import Column, Integer, ForeignKey, DateTime, String
from app.db.database import Base
from pydantic import BaseModel
from datetime import datetime

class Pago(Base):
    __tablename__ = "pagos"
    id = Column(Integer, primary_key=True, index=True)
    pedido_id = Column(Integer, ForeignKey("pedidos.id"), nullable=False)
    fecha_pago = Column(DateTime, default=datetime.utcnow)
    estado_pago_simulado = Column(String(50), default="exitoso")

class PagoCreate(BaseModel):
    pedido_id: int

class PagoOut(BaseModel):
    id: int
    pedido_id: int
    fecha_pago: datetime
    estado_pago_simulado: str

    class Config:
        orm_mode = True
