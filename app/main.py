# main.py
"""
Punto de entrada de la aplicación FastAPI.
Inicializa la app y la base de datos.
"""
from fastapi import FastAPI
from app.db.database import engine, Base
from app.routes import productos, pedidos, pagos

# Crear tablas automáticamente si no existen
def create_tables():
    Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Escolar Simulada")

# Incluir routers
app.include_router(productos.router)
app.include_router(pedidos.router)
app.include_router(pagos.router)

@app.on_event("startup")
def on_startup():
    create_tables()
