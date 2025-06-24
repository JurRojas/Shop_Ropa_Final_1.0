# main.py
"""
Punto de entrada de la aplicación FastAPI.
Inicializa la app y la base de datos.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db.database import engine, Base
from app.routes import productos, pedidos, pagos, clientes, repartidores, login, administradores
from app.models.token_activo import TokenActivo  # Importar el modelo TokenActivo

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
app.include_router(login.router)
app.include_router(administradores.router)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Puedes restringir a ['http://localhost:3000'] o el dominio de tu app Flutter
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    create_tables()
@app.get("/", tags=["Inicio"])
def read_root():
    return {"message": "Bienvenido a la API de la Tienda de Ropa :)"}