# 🚚 Paquexpress App - Sistema de Entregas

Sistema completo de gestión de entregas con API FastAPI y aplicación móvil Flutter.

## 📁 Estructura del Proyecto

paquexpress_app/
├── 📁 api/ # Backend FastAPI
├── 📁 aplicacion/ # Frontend Flutter
├── 📁 bd/ # Scripts de base de datos
└── 📄 README.md # Este archivo


## 🛠️ Tecnologías Utilizadas

### Backend (API)
- **FastAPI** - Framework web moderno
- **Python 3.9+** - Lenguaje de programación
- **MySQL** - Base de datos
- **JWT** - Autenticación por tokens
- **SQLAlchemy** - ORM para base de datos

### Frontend (Flutter)
- **Flutter 3.0+** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **Google Maps** - Integración de mapas
- **Geolocator** - Geolocalización
- **Image Picker** - Captura de fotos

## ⚡ Instalación Rápida

### 1. Base de Datos
```bash
cd bd
# Ejecutar scripts SQL en MySQL

2. Backend (API)

cd api
pip install -r requirements.txt
uvicorn main:api_app --reload --host 0.0.0.0 --port 8000

3. Frontend (Flutter)
cd aplicacion/paquexpress
flutter pub get
flutter run -d chrome

🔧 Configuración
API Endpoints
POST /token - Autenticación

POST /register - Registro de usuarios

GET /packages - Obtener paquetes pendientes

POST /packages/deliver/{id} - Registrar entrega

Variables de Entorno
Actualizar api/app/core/config.py con tu configuración de BD.

📱 Características de la App
✅ Login/Register elegante

✅ Lista de paquetes pendientes

✅ Mapa interactivo con Google Maps

✅ Captura de evidencia fotográfica

✅ Geolocalización en tiempo real

✅ Diseño moderno y responsive

👨‍💻 Desarrollador
Evaristo Junior - GitHub