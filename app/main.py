# main.py
"""
Punto de entrada de la aplicación FastAPI.
Inicializa la app y la base de datos.
"""
from fastapi import FastAPI
from app.db.database import engine, Base
from app.routes import productos, pedidos, pagos, clientes, repartidores

# Crear tablas automáticamente si no existen
def create_tables():
    Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Tienda de ropa")

# Incluir routers
app.include_router(productos.router)
app.include_router(pedidos.router)
app.include_router(pagos.router)
app.include_router(clientes.router)
app.include_router(repartidores.router)

@app.on_event("startup")
def on_startup():
    create_tables()

@app.get("/", tags=["Inicio"])
def read_root():
    """Raíz de la API."""
    return {"message": "Bienvenido a la API de la tienda :)"}