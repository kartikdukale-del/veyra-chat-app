from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from ..core.database import Base


class ConversationMemberModel(Base):
    __tablename__ = "conversations_members"
    __table_args__ = (
        UniqueConstraint("conversation_id", "user_id", name="uq_conversation_member"),
    )

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(
        Integer, ForeignKey("conversations.id"), index=True, nullable=False
    )
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
