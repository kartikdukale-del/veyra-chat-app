from collections import defaultdict
from fastapi import WebSocket


class ConnectionManager:
    """Manages active WebSocket connections grouped by conversation_id and user_id."""

    def __init__(self) -> None:
        self._rooms: dict[int, dict[int, set[WebSocket]]] = defaultdict(
            lambda: defaultdict(set)
        )

    async def connect(
        self, conversation_id: int, user_id: int, websocket: WebSocket
    ) -> None:
        await websocket.accept()
        self._rooms[conversation_id][user_id].add(websocket)

    def disconnect(
        self, conversation_id: int, user_id: int, websocket: WebSocket
    ) -> None:
        users_map = self._rooms.get(conversation_id)
        if not users_map:
            return
        sockets = users_map.get(user_id)
        if sockets:
            sockets.discard(websocket)
            if not sockets:
                users_map.pop(user_id, None)
        if not users_map:
            self._rooms.pop(conversation_id, None)

    async def broadcast_to_conversation(
        self, conversation_id: int, payload: dict
    ) -> None:
        users_map = self._rooms.get(conversation_id)
        if not users_map:
            return

        dead_sockets: list[tuple[int, WebSocket]] = []
        for uid, sockets in list(users_map.items()):
            for ws in list(sockets):
                try:
                    await ws.send_json(payload)
                except Exception:
                    dead_sockets.append((uid, ws))

        for uid, ws in dead_sockets:
            self.disconnect(conversation_id, uid, ws)


ws_manager = ConnectionManager()
