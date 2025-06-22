# administrador.py
"""
Modelo SQLAlchemy y esquema Pydantic para administrador.
"""
from sqlalchemy import Column, Integer, String
from app.db.database import Base
from pydantic import BaseModel, validator

class Administrador(Base):
    __tablename__ = "administradores"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    contrasena = Column(String(128), nullable=False)
    email = Column(String(120), unique=True, nullable=False)

class AdministradorCreate(BaseModel):
    nombre: str
    email: str
    contrasena: str
    
    @validator('email')
    def email_valido(cls, v):
        import re
        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", v):
            raise ValueError('Email inválido')
        return v

class AdministradorOut(BaseModel):
    id: int
    nombre: str
    email: str
    # No exponer la contraseña

    class Config:
        orm_mode = True
