# repartidor.py
"""
Modelo SQLAlchemy y esquema Pydantic para repartidores.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel, Field, validator

class Repartidor(Base):
    __tablename__ = "repartidores"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    telefono = Column(String(20), nullable=False)
    contrasena = Column(String(128), nullable=False)
    email = Column(String(120), unique=True, nullable=False)

class RepartidorCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100, description="Nombre del repartidor")
    telefono: str = Field(..., min_length=10, max_length=10, description="Teléfono, 10 dígitos")
    email: str = Field(..., description="Email del repartidor")
    contrasena: str = Field(..., min_length=6, max_length=128, description="Contraseña del repartidor")

    @validator('email')
    def email_valido(cls, v):
        import re
        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", v):
            raise ValueError('Email inválido')
        return v

class RepartidorOut(BaseModel):
    id: int
    nombre: str
    telefono: str
    email: str

    class Config:
        orm_mode = True
