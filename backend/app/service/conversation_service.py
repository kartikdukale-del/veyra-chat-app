from sqlalchemy import desc, func
from sqlalchemy.orm import Session, aliased
from ..model.conversation_model import CoversationModel
from ..model.conversation_member_model import ConversationMemberModel
from ..model.message_model import MessageModel
from ..model.user_model import UserModel


def create_or_get_conversation(
    target_user_id: int,
    current_user: UserModel,
    db: Session,
):
    target_user = (
        db.query(UserModel).filter(UserModel.id == target_user_id).first()
    )
    if target_user is None or current_user.id == target_user_id:
        return None

    member1 = aliased(ConversationMemberModel)
    member2 = aliased(ConversationMemberModel)

    conversation = (
        db.query(CoversationModel)
        .join(member1, CoversationModel.id == member1.conversation_id)
        .join(member2, CoversationModel.id == member2.conversation_id)
        .filter(
            member1.user_id == current_user.id,
            member2.user_id == target_user_id,
        )
        .first()
    )
    if conversation:
        return conversation

    new_conversation = CoversationModel(created_by=current_user.id)
    db.add(new_conversation)
    db.flush()

    members = [
        ConversationMemberModel(
            conversation_id=new_conversation.id,
            user_id=current_user.id,
        ),
        ConversationMemberModel(
            conversation_id=new_conversation.id,
            user_id=target_user.id,
        ),
    ]
    db.add_all(members)
    db.commit()
    db.refresh(new_conversation)

    return new_conversation


def get_user_conversations(current_user: UserModel, db: Session) -> list[dict]:
    """Return all conversations for current_user ordered by latest activity."""
    my_memberships = (
        db.query(ConversationMemberModel.conversation_id)
        .filter(ConversationMemberModel.user_id == current_user.id)
        .all()
    )
    conv_ids = [row[0] for row in my_memberships]
    if not conv_ids:
        return []

    other_rows = (
        db.query(ConversationMemberModel.conversation_id, UserModel)
        .join(UserModel, UserModel.id == ConversationMemberModel.user_id)
        .filter(
            ConversationMemberModel.conversation_id.in_(conv_ids),
            ConversationMemberModel.user_id != current_user.id,
        )
        .all()
    )
    other_user_by_conv = {conv_id: user for conv_id, user in other_rows}

    # Subquery to find latest message id per conversation
    latest_msg_subq = (
        db.query(
            MessageModel.conversation_id,
            func.max(MessageModel.id).label("max_id"),
        )
        .filter(MessageModel.conversation_id.in_(conv_ids))
        .group_by(MessageModel.conversation_id)
        .subquery()
    )

    latest_msgs = (
        db.query(MessageModel)
        .join(latest_msg_subq, MessageModel.id == latest_msg_subq.c.max_id)
        .all()
    )
    latest_by_conv = {msg.conversation_id: msg for msg in latest_msgs}

    conversations = (
        db.query(CoversationModel)
        .filter(CoversationModel.id.in_(conv_ids))
        .order_by(desc(CoversationModel.created_at))
        .all()
    )

    results: list[dict] = []
    for conv in conversations:
        other_user = other_user_by_conv.get(conv.id)
        if other_user is None:
            continue
        if (
            other_user.email == "testuser123@example.com"
            or other_user.full_name == "Test User"
        ):
            continue

        last_msg = latest_by_conv.get(conv.id)
        activity_dt = last_msg.created_at if last_msg else conv.created_at

        results.append(
            {
                "conversation_id": conv.id,
                "other_user": {
                    "id": other_user.id,
                    "full_name": other_user.full_name,
                    "email": other_user.email,
                    "about": other_user.about or "Available",
                },
                "last_message": last_msg.content if last_msg else None,
                "last_message_at": (
                    last_msg.created_at.isoformat() if last_msg else None
                ),
                "last_message_sender_id": (
                    last_msg.sender_id if last_msg else None
                ),
                "_sort_ts": activity_dt,
            }
        )

    results.sort(key=lambda item: item["_sort_ts"], reverse=True)
    for item in results:
        item.pop("_sort_ts", None)

    return results
