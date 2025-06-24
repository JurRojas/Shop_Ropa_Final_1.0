# tarjeta.py
"""
Modelo SQLAlchemy para tarjetas de usuario.
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base
from datetime import datetime

class Tarjeta(Base):
    __tablename__ = "tarjetas"
    id = Column(Integer, primary_key=True, index=True)
    cliente_id = Column(Integer, ForeignKey('clientes.id'), nullable=False)
    numero = Column(String(20), nullable=False)
    nombre = Column(String(100), nullable=False)
    vencimiento = Column(String(7), nullable=False)  # MM/AAAA
    cvv = Column(String(3), nullable=False)
    creada_en = Column(DateTime, default=datetime.utcnow)

    cliente = relationship("Cliente", back_populates="tarjetas")
