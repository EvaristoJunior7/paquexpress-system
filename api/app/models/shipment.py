from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from app.core.database import Base

class Shipment(Base):
    __tablename__ = "packages"

    id = Column(Integer, primary_key=True, index=True)
    tracking_number = Column(String(20), unique=True)
    address = Column(String(255))
    customer_name = Column(String(100))
    latitude = Column(Float)
    longitude = Column(Float)
    status = Column(String(20), default="PENDING")
    assigned_to = Column(Integer, ForeignKey("users.id"))
    evidence_photo_path = Column(String(255))
    delivery_latitude = Column(Float)
    delivery_longitude = Column(Float)
    delivered_at = Column(DateTime)
