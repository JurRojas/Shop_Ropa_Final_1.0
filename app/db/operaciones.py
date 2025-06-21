# operaciones.py
"""
Funciones de acceso a datos y validaciones comunes.
"""
from sqlalchemy.orm import Session
from app.models import cliente, repartidor, pedido

# Ejemplo de validación: verificar si un cliente existe
def cliente_existe(db: Session, cliente_id: int) -> bool:
    return db.query(cliente.Cliente).filter(cliente.Cliente.id == cliente_id).first() is not None

# Ejemplo de validación: verificar si un repartidor existe
def repartidor_existe(db: Session, repartidor_id: int) -> bool:
    return db.query(repartidor.Repartidor).filter(repartidor.Repartidor.id == repartidor_id).first() is not None

# Ejemplo de validación: verificar si un pedido existe
def pedido_existe(db: Session, pedido_id: int) -> bool:
    return db.query(pedido.Pedido).filter(pedido.Pedido.id == pedido_id).first() is not None
