from fastapi import FastAPI
from app.core.database import Base, engine
from app.model import (UserModel, CoversationModel,
                       ConversationMemberModel, MessageModel)
from app.route.user_route import router as user_router
from fastapi.middleware.cors import CORSMiddleware
app = FastAPI(
    title="Verya App",
    version="1.0.0"
)
app.include_router(user_router)
Base.metadata.create_all(bind=engine)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "Verya app running"}
