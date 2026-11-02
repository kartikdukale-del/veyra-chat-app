from sqlalchemy.orm import Session
from ..model.message_model import MessageModel
from ..model.conversation_member_model import ConversationMemberModel


def get_messages(
        conversation_id: int,
        current_user_id: int,
        db: Session
):
    memberShip = db.query(ConversationMemberModel).filter(
        ConversationMemberModel.conversation_id == conversation_id,
        ConversationMemberModel.user_id == current_user_id
    ).first()

    if memberShip is None:
        return None
    messages =db.query(MessageModel).filter(
        MessageModel.conversation_id == conversation_id
    ).order_by(MessageModel.created_at.asc()).all()

    return messages

def send_message(
        conversation_id:int,
        current_user_id: int,
        content: str,
        db:Session
):
    membership = db.query(ConversationMemberModel).filter(
        ConversationMemberModel.conversation_id == conversation_id,
        ConversationMemberModel.user_id == current_user_id
    ).first()

    if membership is None:
        return None

    new_message = MessageModel(
        conversation_id = conversation_id,
        sender_id= current_user_id,
        content = content
    )

    db.add(new_message)
    db.commit()
    db.refresh(new_message)

    return new_message