# repartidor.py
"""
Modelo SQLAlchemy y esquema Pydantic para repartidores.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel

class Repartidor(Base):
    __tablename__ = "repartidores"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    telefono = Column(String(20), nullable=False)

class RepartidorCreate(BaseModel):
    nombre: str
    telefono: str

class RepartidorOut(BaseModel):
    id: int
    nombre: str
    telefono: str

    class Config:
        orm_mode = True
