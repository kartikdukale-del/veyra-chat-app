import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL environment variable is not set")

# Render PostgreSQL sometimes uses postgres:// which SQLAlchemy 2.x expects as postgresql+psycopg://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg://", 1)
elif DATABASE_URL.startswith("postgresql://") and "+psycopg" not in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg://", 1)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
)
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def run_safe_migrations():
    """Apply non-destructive schema additions and indexes if missing."""
    statements = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS about VARCHAR(255) DEFAULT 'Available'",
        "ALTER TABLE messages ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ",
        "CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages (conversation_id)",
        "CREATE INDEX IF NOT EXISTS idx_conv_members_user_id ON conversations_members (user_id)",
        "CREATE INDEX IF NOT EXISTS idx_conv_members_conv_id ON conversations_members (conversation_id)",
    ]
    with engine.begin() as conn:
        for stmt in statements:
            conn.execute(text(stmt))
