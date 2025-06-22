# producto.py
"""
Modelo SQLAlchemy y esquema Pydantic para productos.
"""
from sqlalchemy import Column, Integer, String, Float
from app.db.database import Base
from pydantic import BaseModel, Field

class Producto(Base):
    __tablename__ = "productos"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(String(255))
    precio = Column(Float, nullable=False)
    imagen_url = Column(String(255))

class ProductoCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100, description="Nombre del producto")
    descripcion: str = Field(None, max_length=255, description="Descripción del producto")
    precio: float = Field(..., gt=0, description="Precio mayor a 0")
    imagen_url: str = Field(None, max_length=255, description="URL de la imagen")

class ProductoOut(BaseModel):
    id: int
    nombre: str
    descripcion: str = None
    precio: float
    imagen_url: str = None

    class Config:
        orm_mode = True
