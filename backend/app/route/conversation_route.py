from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..model.user_model import UserModel
from ..service.conversation_service import create_or_get_conversation
from ..core.security import get_current_user

router = APIRouter(
    prefix = "/conversations",
    tags = ["Conversations"]
)

@router.post("/")
def create_conversation_api(
    target_user_id:int,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user)
):
    conversation =create_or_get_conversation(
        target_user_id,
        current_user,
        db
    )
    if conversation is None:
        raise HTTPException(
            status_code=404,
            detail="User not Found or invalid user"
        )
    return {
            "message":"Conversation created succesfuly",
            "conversation_id": conversation.id
    }
