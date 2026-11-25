from sqlalchemy import Column, Integer, String, DateTime, func
from ..core.database import Base


class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    about = Column(String(255), nullable=True, server_default="Available")
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
