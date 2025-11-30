import os
from pathlib import Path

# Configuración de base de datos
DB_CONNECTION_STRING = "mysql+pymysql://root:@localhost:3307/paquexpress_db"
JWT_SECRET = "mi_super_secreto_key"
ENCRYPTION_ALGO = "HS256"
TOKEN_DURATION_MINUTES = 60

# ✅ GARANTIZAR que la carpeta de evidencias existe
EVIDENCE_FOLDER = "evidencias"

# Crear carpeta si no existe (absoluta para evitar problemas)
evidence_path = Path(EVIDENCE_FOLDER)
evidence_path.mkdir(exist_ok=True)

print(f"📁 Carpeta de evidencias: {evidence_path.absolute()}")