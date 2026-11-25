from pydantic import BaseModel, Field


class MessageCreate(BaseModel):
    content: str = Field(min_length=1, max_length=5000)
    client_msg_id: str | None = None


class MessageUpdate(BaseModel):
    content: str = Field(min_length=1, max_length=5000)
