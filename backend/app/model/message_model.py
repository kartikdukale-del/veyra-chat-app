from sqlalchemy import Column,Integer,String,DateTime,ForeignKey,func
from ..core.database import Base

class MessageModel(Base):
    __tablename__ = "messages"

    id = Column(Integer,primary_key=True,index=True)
    conversation_id = Column(Integer,ForeignKey('conversations.id'),nullable=False)
    sender_id = Column(Integer,ForeignKey('users.id'),nullable=False)
    content = Column(String(5000),nullable=False)
    created_at = Column(DateTime(timezone=True),server_default=func.now(),nullable=False)
    