# cliente.py
"""
Modelo SQLAlchemy y esquema Pydantic para clientes.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel, Field

class Cliente(Base):
    __tablename__ = "clientes"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    direccion = Column(String(255), nullable=False)
    contrasena = Column(String(128), nullable=False)

class ClienteCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100, description="Nombre del cliente")
    direccion: str = Field(..., min_length=5, max_length=255, description="Dirección del cliente")
    contrasena: str = Field(..., min_length=8, max_length=128, description="Contraseña del cliente")

class ClienteOut(BaseModel):
    id: int
    nombre: str
    direccion: str

    class Config:
        orm_mode = True
