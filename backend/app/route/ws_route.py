from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect
from ..core.database import SessionLocal
from ..core.security import decode_access_token
from ..core.ws_manager import ws_manager
from ..service.message_service import (
    is_conversation_member,
    send_message,
    serialize_message,
)

router = APIRouter(tags=["WebSocket"])


@router.websocket("/ws/conversations/{conversation_id}")
async def conversation_websocket(
    websocket: WebSocket,
    conversation_id: int,
    token: str | None = Query(default=None),
):
    auth_token = token
    if not auth_token:
        auth_header = websocket.headers.get("authorization")
        if auth_header and auth_header.lower().startswith("bearer "):
            auth_token = auth_header.split(" ", 1)[1].strip()

    if not auth_token:
        await websocket.close(code=4001, reason="Missing authentication token")
        return

    db = SessionLocal()
    try:
        user = decode_access_token(auth_token, db)
        if user is None:
            await websocket.close(code=4001, reason="Invalid or expired token")
            return

        if not is_conversation_member(conversation_id, user.id, db):
            await websocket.close(
                code=4003, reason="Not a member of this conversation"
            )
            return

        user_id = user.id
    finally:
        db.close()

    await ws_manager.connect(conversation_id, user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            event_type = data.get("type")

            if event_type == "ping":
                await websocket.send_json({"type": "pong"})
            elif event_type == "send_message":
                content = str(data.get("content", ""))
                client_msg_id = data.get("client_msg_id")

                msg_db = SessionLocal()
                try:
                    msg = send_message(conversation_id, user_id, content, msg_db)
                    if msg is None or msg == "EMPTY":
                        await websocket.send_json(
                            {
                                "type": "error",
                                "detail": "Unable to send message",
                                "client_msg_id": client_msg_id,
                            }
                        )
                        continue
                    serialized = serialize_message(msg)
                finally:
                    msg_db.close()

                await ws_manager.broadcast_to_conversation(
                    conversation_id,
                    {
                        "type": "new_message",
                        "message": serialized,
                        "client_msg_id": client_msg_id,
                    },
                )
    except WebSocketDisconnect:
        ws_manager.disconnect(conversation_id, user_id, websocket)
    except Exception:
        ws_manager.disconnect(conversation_id, user_id, websocket)
