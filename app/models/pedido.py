# pedido.py
"""
Modelo SQLAlchemy y esquemas Pydantic para pedidos y detalle_pedido.
"""
from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.db.database import Base
from pydantic import BaseModel, Field
from datetime import datetime

class Pedido(Base):
    __tablename__ = "pedidos"
    id = Column(Integer, primary_key=True, index=True)
    cliente_id = Column(Integer, ForeignKey("clientes.id"), nullable=False)
    repartidor_id = Column(Integer, ForeignKey("repartidores.id"), nullable=True)
    estado = Column(String(50), nullable=False, default="pendiente")
    total = Column(Float, nullable=False)
    fecha = Column(DateTime, default=datetime.utcnow)
    detalles = relationship("DetallePedido", back_populates="pedido")

class DetallePedido(Base):
    __tablename__ = "detalle_pedido"
    id = Column(Integer, primary_key=True, index=True)
    pedido_id = Column(Integer, ForeignKey("pedidos.id"), nullable=False)
    producto_id = Column(Integer, ForeignKey("productos.id"), nullable=False)
    cantidad = Column(Integer, nullable=False)
    pedido = relationship("Pedido", back_populates="detalles")

class DetallePedidoCreate(BaseModel):
    producto_id: int = Field(..., gt=0, description="ID de producto válido")
    cantidad: int = Field(..., gt=0, description="Cantidad mayor a 0")

class PedidoCreate(BaseModel):
    cliente_id: int = Field(..., gt=0, description="ID de cliente válido")
    detalles: list[DetallePedidoCreate] = Field(..., min_items=1, description="Lista de detalles, al menos uno")
    total: float = Field(..., gt=0, description="Total mayor a 0")

class PedidoOut(BaseModel):
    id: int
    cliente_id: int
    repartidor_id: int | None
    estado: str
    total: float
    fecha: datetime
    detalles: list[DetallePedidoCreate]

    class Config:
        orm_mode = True
