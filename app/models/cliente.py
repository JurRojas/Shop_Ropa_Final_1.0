# cliente.py
"""
Modelo SQLAlchemy y esquema Pydantic para clientes.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel

class Cliente(Base):
    __tablename__ = "clientes"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    direccion = Column(String(255), nullable=False)

class ClienteCreate(BaseModel):
    nombre: str
    direccion: str

class ClienteOut(BaseModel):
    id: int
    nombre: str
    direccion: str

    class Config:
        orm_mode = True
