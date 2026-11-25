from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import get_current_user
from ..core.ws_manager import ws_manager
from ..model.user_model import UserModel
from ..schema.message_schema import MessageCreate, MessageUpdate
from ..service.message_service import (
    delete_message,
    get_messages,
    send_message,
    serialize_message,
    update_message,
)

router = APIRouter(prefix="/conversations", tags=["Messages"])


@router.get("/{conversation_id}/messages")
def get_messages_api(
    conversation_id: int,
    after_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    messages = get_messages(
        conversation_id,
        current_user.id,
        db,
        after_id=after_id,
    )
    if messages is None:
        raise HTTPException(
            status_code=403,
            detail="You are not a member of this conversation",
        )
    return [serialize_message(message) for message in messages]


@router.post("/{conversation_id}/messages")
async def send_message_api(
    conversation_id: int,
    payload: MessageCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    message = send_message(
        conversation_id,
        current_user.id,
        payload.content,
        db,
    )
    if message is None:
        raise HTTPException(
            status_code=403,
            detail="You are not a member of this conversation",
        )
    if message == "EMPTY":
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    serialized = serialize_message(message)
    await ws_manager.broadcast_to_conversation(
        conversation_id,
        {
            "type": "new_message",
            "message": serialized,
            "client_msg_id": payload.client_msg_id,
        },
    )
    return serialized


@router.patch("/{conversation_id}/messages/{message_id}")
async def update_message_api(
    conversation_id: int,
    message_id: int,
    payload: MessageUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    updated, err = update_message(
        conversation_id,
        message_id,
        current_user.id,
        payload.content,
        db,
    )
    if err == "NOT_MEMBER":
        raise HTTPException(
            status_code=403, detail="You are not a member of this conversation"
        )
    if err == "NOT_FOUND":
        raise HTTPException(status_code=404, detail="Message not found")
    if err == "NOT_OWNER":
        raise HTTPException(
            status_code=403, detail="You can only edit your own messages"
        )
    if err == "EMPTY":
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    serialized = serialize_message(updated)
    await ws_manager.broadcast_to_conversation(
        conversation_id,
        {
            "type": "message_updated",
            "message": serialized,
        },
    )
    return serialized


@router.delete("/{conversation_id}/messages/{message_id}")
async def delete_message_api(
    conversation_id: int,
    message_id: int,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    ok, err = delete_message(
        conversation_id,
        message_id,
        current_user.id,
        db,
    )
    if err == "NOT_MEMBER":
        raise HTTPException(
            status_code=403, detail="You are not a member of this conversation"
        )
    if err == "NOT_FOUND":
        raise HTTPException(status_code=404, detail="Message not found")
    if err == "NOT_OWNER":
        raise HTTPException(
            status_code=403, detail="You can only delete your own messages"
        )

    await ws_manager.broadcast_to_conversation(
        conversation_id,
        {
            "type": "message_deleted",
            "conversation_id": conversation_id,
            "message_id": message_id,
        },
    )
    return {"deleted": True, "message_id": message_id}
