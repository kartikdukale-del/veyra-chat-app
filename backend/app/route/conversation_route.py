from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import get_current_user
from ..model.user_model import UserModel
from ..service.conversation_service import (
    create_or_get_conversation,
    get_user_conversations,
)

router = APIRouter(prefix="/conversations", tags=["Conversations"])


@router.get("/")
def list_conversations_api(
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    return get_user_conversations(current_user, db)


@router.post("/")
def create_conversation_api(
    target_user_id: int,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    conversation = create_or_get_conversation(
        target_user_id,
        current_user,
        db,
    )
    if conversation is None:
        raise HTTPException(
            status_code=404,
            detail="User not found or invalid user",
        )
    return {
        "message": "Conversation created successfully",
        "conversation_id": conversation.id,
    }
