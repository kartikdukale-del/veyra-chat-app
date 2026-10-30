from sqlalchemy import Column,Integer,String,DateTime,ForeignKey, func
from ..core.database import Base

class CoversationModel(Base):
    __tablename__ = "conversations"

    id = Column(Integer,primary_key=True,index=True)
   
    created_by = Column(Integer,ForeignKey('users.id'),nullable=False)
    created_at = Column(DateTime(timezone=True),server_default=func.now(),nullable=False)
    