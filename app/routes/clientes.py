# clientes.py
"""
Rutas para gestión de clientes.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user
from app.models.cliente import Cliente, ClienteCreate, ClienteOut
from typing import List
from app.security import hash_password

router = APIRouter(prefix="/clientes", tags=["Clientes"])

@router.post("/", response_model=ClienteOut)
def crear_cliente(cliente: ClienteCreate, db: Session = Depends(get_db)):
    """Crea un nuevo cliente."""
    if db.query(Cliente).filter(Cliente.email == cliente.email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    hashed_password = hash_password(cliente.contrasena)
    db_cliente = Cliente(nombre=cliente.nombre, direccion=cliente.direccion, email=cliente.email, contrasena=hashed_password)
    db.add(db_cliente)
    db.commit()
    db.refresh(db_cliente)
    return db_cliente

# @router.get("/", response_model=List[ClienteOut])
# def listar_clientes(db: Session = Depends(get_db), user=Depends(get_current_user)):
#     """Lista todos los clientes."""
#     return db.query(Cliente).all()

# @router.get("/{cliente_id}", response_model=ClienteOut)
# def obtener_cliente(cliente_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
#     if user["user_tipo"] != "administrador":
#         raise HTTPException(status_code=403, detail="Solo el administrador puede consultar clientes")
#     cliente = db.query(Cliente).filter(Cliente.id == cliente_id).first()
#     if not cliente:
#         raise HTTPException(status_code=404, detail="Cliente no encontrado")
#     return cliente

# @router.put("/{cliente_id}", response_model=ClienteOut)
# def actualizar_cliente(cliente_id: int, cliente: ClienteCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
#     if user["user_tipo"] != "administrador":
#         raise HTTPException(status_code=403, detail="Solo el administrador puede modificar clientes")
#     db_cliente = db.query(Cliente).filter(Cliente.id == cliente_id).first()
#     if not db_cliente:
#         raise HTTPException(status_code=404, detail="Cliente no encontrado")
#     db_cliente.nombre = cliente.nombre
#     db_cliente.direccion = cliente.direccion
#     db_cliente.email = cliente.email
#     db_cliente.contrasena = hash_password(cliente.contrasena)
#     db.commit()
#     db.refresh(db_cliente)
#     return db_cliente

# @router.delete("/{cliente_id}", status_code=status.HTTP_204_NO_CONTENT)
# def eliminar_cliente(cliente_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
#     if user["user_tipo"] != "administrador":
#         raise HTTPException(status_code=403, detail="Solo el administrador puede eliminar clientes")
#     cliente = db.query(Cliente).filter(Cliente.id == cliente_id).first()
#     if not cliente:
#         raise HTTPException(status_code=404, detail="Cliente no encontrado")
#     db.delete(cliente)
#     db.commit()
#     return None
