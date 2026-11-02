from fastapi import APIRouter,Depends,HTTPException,Body
from sqlalchemy.orm import Session


from ..core.database import get_db
from ..core.security import get_current_user
from ..model.user_model import UserModel
from ..service.message_service import get_messages, send_message

router = APIRouter(
    prefix="/conversations",
    tags=["Messages"]
)

@router.get("/{conversation_id}/messages")
def get_messages_api(
    conversation_id : int,
    db:Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user)
): 
    messages = get_messages(
        conversation_id,
        current_user.id,
        db
    )
    if messages is None:
        raise HTTPException(
            status_code=403,
            detail="Yor are not member of this conversation"
        )
    return [
        {
            "id":message.id,
            "conversation_id":message.conversation_id,
            "sender_id":message.sender_id,
            "content":message.content,
            "created_at":message.created_at
        }
        for message in messages
    ]


@router.post("/{conversation_id}/messages")
def send_message_api(
    conversation_id: int,
    content: str = Body(embed=True),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user)
):
    message = send_message(
        conversation_id,
        current_user.id,
        content,
        db
    )

    if message is None:
        raise HTTPException(
            status_code=403,
            detail="You are not member of this conversation"
        )

    return {
        "id" : message.id,
        "conversation_id" : message.conversation_id,
        "sender_id" : message.id,
        "content" : message.content,
        "created_at" : message.created_at
    }