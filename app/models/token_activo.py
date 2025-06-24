# token_activo.py
"""
Modelo SQLAlchemy para tokens activos de usuario.
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base
from datetime import datetime

class TokenActivo(Base):
    __tablename__ = "tokens_activos"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)  # Puede ser cliente, repartidor o admin
    user_tipo = Column(String(20), nullable=False)  # 'cliente', 'repartidor', 'administrador'
    token = Column(String(512), nullable=False, unique=True)
    creado_en = Column(DateTime, default=datetime.utcnow)
    expira_en = Column(DateTime, nullable=False)
