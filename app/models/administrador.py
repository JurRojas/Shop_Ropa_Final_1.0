# administrador.py
"""
Modelo SQLAlchemy y esquema Pydantic para administrador.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel

class Administrador(Base):
    __tablename__ = "administradores"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    contrasena = Column(String(128), nullable=False)

class AdministradorCreate(BaseModel):
    nombre: str
    contrasena: str

class AdministradorOut(BaseModel):
    id: int
    nombre: str
    # No exponer la contraseña

    class Config:
        orm_mode = True
