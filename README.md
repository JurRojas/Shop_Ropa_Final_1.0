
# 📱 API para Aplicación de Negocio Local (Flutter + FastAPI + MySQL)

Este proyecto es una práctica escolar que simula una API REST usando **FastAPI** y **MySQL (XAMPP)** como base de datos relacional. La aplicación móvil se desarrolla con **Flutter** y tiene tres tipos de usuarios: Cliente, Repartidor y Propietario.

---

## 🇪🇸 Español

### ✅ Características principales

- API desarrollada en FastAPI.
- Base de datos relacional en MySQL (usando XAMPP).
- Creación automática de la base de datos y tablas si no existen.
- División por módulos: modelos, rutas, controladores y base de datos.
- Sin autenticación real ni pasarelas de pago (los pagos son simulados).
- Compatible con Flutter para consumir la API.

### 🧾 Perfiles de usuario y funciones

| Rol         | Funcionalidad Principal |
|-------------|--------------------------|
| Cliente     | Ver productos, hacer pedidos, simular pagos |
| Repartidor  | Ver pedidos asignados, cambiar estado |
| Propietario | Ver todos los pedidos, asignar repartidores, ver entregas |

### 📦 Estructura del Proyecto

```
/app/
├── main.py
├── models/
├── routes/
├── db/
```

### 🚀 Cómo iniciar

1. Instala dependencias:
```bash
pip install -r requirements.txt
ó
pip install fastapi uvicorn sqlalchemy pymysql
```

2. Inicia el servidor:
```bash
uvicorn app.main:app --reload
```

3. Accede a la documentación interactiva:
```
http://127.0.0.1:8000/docs
```

---

## 🇺🇸 English

### ✅ Main Features

- API built with FastAPI.
- Relational database using MySQL (via XAMPP).
- Auto-create database and tables if they don't exist.
- Modular project structure: models, routes, controllers, db.
- No real authentication or payment gateways (payments are simulated).
- Designed to be consumed by a Flutter mobile app.

### 🧾 User Roles and Features

| Role        | Main Features |
|-------------|----------------|
| Customer    | View products, place orders, simulate payments |
| Deliveryman | View assigned orders, update status |
| Owner       | View all orders, assign deliverymen, view deliveries |

### 📦 Project Structure

```
/app/
├── main.py
├── models/
├── routes/
├── db/
```

### 🚀 How to Run

1. Install dependencies:
```bash
pip install fastapi uvicorn sqlalchemy pymysql
```

2. Start the server:
```bash
uvicorn app.main:app --reload
```

3. Access Swagger documentation:
```
http://127.0.0.1:8000/docs
```
