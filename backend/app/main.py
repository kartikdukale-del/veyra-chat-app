from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import Base, engine, run_safe_migrations
from app.model import (  # noqa: F401
    UserModel,
    CoversationModel,
    ConversationMemberModel,
    MessageModel,
)
from app.route.user_route import router as user_router
from app.route.conversation_route import router as conversation_router
from app.route.message_route import router as message_router
from app.route.ws_route import router as ws_router

app = FastAPI(
    title="Verya App",
    version="1.0.0",
)

app.include_router(user_router)
app.include_router(conversation_router)
app.include_router(message_router)
app.include_router(ws_router)

Base.metadata.create_all(bind=engine)
run_safe_migrations()

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "Verya app running"}


@app.get("/health")
def health():
    return {"status": "ok"}
