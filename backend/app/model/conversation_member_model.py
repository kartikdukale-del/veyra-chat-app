from sqlalchemy import Column,Integer,ForeignKey
from ..core.database import Base

class ConversationMemberModel(Base):
    __tablename__ = "conversations_members"

    id = Column(Integer,primary_key=True,index=True)
    conversation_id = Column(Integer,ForeignKey('conversations.id'),nullable=False)
    user_id = Column(Integer,ForeignKey('users.id'),nullable=False)
