from datetime import datetime, timezone
from sqlalchemy.orm import Session
from ..model.message_model import MessageModel
from ..model.conversation_member_model import ConversationMemberModel


def is_conversation_member(
    conversation_id: int, user_id: int, db: Session
) -> bool:
    membership = (
        db.query(ConversationMemberModel)
        .filter(
            ConversationMemberModel.conversation_id == conversation_id,
            ConversationMemberModel.user_id == user_id,
        )
        .first()
    )
    return membership is not None


def serialize_message(message: MessageModel) -> dict:
    return {
        "id": message.id,
        "conversation_id": message.conversation_id,
        "sender_id": message.sender_id,
        "content": message.content,
        "created_at": (
            message.created_at.isoformat() if message.created_at else None
        ),
        "updated_at": (
            message.updated_at.isoformat() if message.updated_at else None
        ),
    }


def get_messages(
    conversation_id: int,
    current_user_id: int,
    db: Session,
    after_id: int | None = None,
):
    if not is_conversation_member(conversation_id, current_user_id, db):
        return None

    query = db.query(MessageModel).filter(
        MessageModel.conversation_id == conversation_id
    )
    if after_id is not None:
        query = query.filter(MessageModel.id > after_id)

    return query.order_by(
        MessageModel.created_at.asc(), MessageModel.id.asc()
    ).all()


def send_message(
    conversation_id: int,
    current_user_id: int,
    content: str,
    db: Session,
):
    if not is_conversation_member(conversation_id, current_user_id, db):
        return None

    cleaned = content.strip()
    if not cleaned:
        return "EMPTY"

    new_message = MessageModel(
        conversation_id=conversation_id,
        sender_id=current_user_id,
        content=cleaned,
    )
    db.add(new_message)
    db.commit()
    db.refresh(new_message)
    return new_message


def update_message(
    conversation_id: int,
    message_id: int,
    current_user_id: int,
    content: str,
    db: Session,
):
    if not is_conversation_member(conversation_id, current_user_id, db):
        return None, "NOT_MEMBER"

    msg = (
        db.query(MessageModel)
        .filter(
            MessageModel.id == message_id,
            MessageModel.conversation_id == conversation_id,
        )
        .first()
    )
    if msg is None:
        return None, "NOT_FOUND"
    if msg.sender_id != current_user_id:
        return None, "NOT_OWNER"

    cleaned = content.strip()
    if not cleaned:
        return None, "EMPTY"

    msg.content = cleaned
    msg.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(msg)
    return msg, None


def delete_message(
    conversation_id: int,
    message_id: int,
    current_user_id: int,
    db: Session,
):
    if not is_conversation_member(conversation_id, current_user_id, db):
        return False, "NOT_MEMBER"

    msg = (
        db.query(MessageModel)
        .filter(
            MessageModel.id == message_id,
            MessageModel.conversation_id == conversation_id,
        )
        .first()
    )
    if msg is None:
        return False, "NOT_FOUND"
    if msg.sender_id != current_user_id:
        return False, "NOT_OWNER"

    db.delete(msg)
    db.commit()
    return True, None
