from sqlalchemy.orm import Session,aliased 
from ..model.conversation_model import CoversationModel
from ..model.conversation_member_model import ConversationMemberModel
from ..model.user_model import UserModel

def create_or_get_conversation(
        target_user_id: int,
        current_user:UserModel,
        db:Session
):
    target_user = db.query(UserModel).filter(
       UserModel.id == target_user_id 
    ).first()

    if target_user is None:
        return None
    if current_user.id == target_user_id:
        return None
    member1 = aliased(ConversationMemberModel)
    member2 = aliased(ConversationMemberModel)

    conversation = (
        db.query(CoversationModel)
        .join(
            member1,
            CoversationModel.id == member1.conversation_id
        )
        .join(
            member2,
            CoversationModel.id == member2.conversation_id
        )
        .filter(
            member1.user_id == current_user.id,
            member2.user_id == target_user_id 
        )
        .first()
    )
    if conversation:
        return conversation

    new_conversation = CoversationModel(
        created_by =current_user.id
    )
    db.add(new_conversation)
    db.flush()

    members = [
        ConversationMemberModel(
            conversation_id = new_conversation.id,
            user_id = current_user.id
        ),
        ConversationMemberModel(
            conversation_id = new_conversation.id,
            user_id = target_user.id
        )
    ]
    db.add_all(members)
    db.commit()
    db.refresh(new_conversation)

    return new_conversation