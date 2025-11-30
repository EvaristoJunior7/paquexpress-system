from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from datetime import datetime
import os

from app.models.shipment import Shipment
from app.models.agent import Agent
from app.core.database import get_db
from app.core.security import get_current_agent
from app.core.config import EVIDENCE_FOLDER

router = APIRouter(prefix="/packages", tags=["Shipments"])


@router.get("/")
def get_packages(agent: Agent = Depends(get_current_agent), db: Session = Depends(get_db)):
    """Obtener paquetes pendientes del agente - CON VALIDACIÓN"""
    return db.query(Shipment).filter(
        Shipment.assigned_to == agent.id,
        Shipment.status == "PENDING"
    ).all()


@router.post("/deliver/{pkg_id}")
def deliver_package(
    pkg_id: int,
    lat: float = Form(...),
    lon: float = Form(...),
    file: UploadFile = File(...),
    agent: Agent = Depends(get_current_agent),
    db: Session = Depends(get_db)
):
    """Registrar entrega - SIN VALIDACIONES EXTRAS (COMO EL ORIGINAL)"""
    
    # ✅ COMO EL ORIGINAL: Solo verificar que existe el paquete
    pkg = db.query(Shipment).filter(Shipment.id == pkg_id).first()
    
    if not pkg:
        raise HTTPException(status_code=404, detail="Paquete no localizado")
    
    # ✅ COMO EL ORIGINAL: Nombre simple del archivo
    image_filename = f"{pkg.tracking_number}_evidence.jpg"
    image_save_path = f"{EVIDENCE_FOLDER}/{image_filename}"
    
    # ✅ COMO EL ORIGINAL: Escritura directa
    with open(image_save_path, "wb+") as img_buffer:
        img_buffer.write(file.file.read())
    
    # ✅ COMO EL ORIGINAL: Actualización directa
    pkg.status = "DELIVERED"
    pkg.evidence_photo_path = image_save_path
    pkg.delivery_latitude = lat
    pkg.delivery_longitude = lon
    pkg.delivered_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Entrega confirmada y evidencia guardada"}