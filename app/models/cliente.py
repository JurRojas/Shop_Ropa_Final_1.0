# cliente.py
"""
Modelo SQLAlchemy y esquema Pydantic para clientes.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel, Field, validator
from sqlalchemy.orm import relationship

class Cliente(Base):
    __tablename__ = "clientes"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    direccion = Column(String(255), nullable=False)
    contrasena = Column(String(128), nullable=False)
    email = Column(String(120), unique=True, nullable=False)

    tarjetas = relationship("Tarjeta", back_populates="cliente")

class ClienteCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100, description="Nombre del cliente")
    direccion: str = Field(..., min_length=5, max_length=255, description="Dirección del cliente")
    email: str = Field(..., description="Email del cliente")
    contrasena: str = Field(..., min_length=8, max_length=128, description="Contraseña del cliente")

    @validator('email')
    def email_valido(cls, v):
        import re
        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", v):
            raise ValueError('Email inválido')
        return v

class ClienteOut(BaseModel):
    id: int
    nombre: str
    direccion: str
    email: str

    class Config:
        orm_mode = True
