from sqlalchemy.orm import Session
from pwdlib import PasswordHash
from ..core.security import create_access_token
from ..model.user_model import UserModel
from ..schema.user_schema import UserCreate, UserUpdate

password_hash = PasswordHash.recommended()


def create_user(user: UserCreate, db: Session):
    normalized_email = user.email.strip().lower()
    existing_user = (
        db.query(UserModel)
        .filter(UserModel.email == normalized_email)
        .first()
    )
    if existing_user:
        return None
    hashed_password = password_hash.hash(user.password)

    new_user = UserModel(
        full_name=user.full_name.strip(),
        email=normalized_email,
        hashed_password=hashed_password,
        about="Available",
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def login_user(email: str, password: str, db: Session):
    normalized_email = email.strip().lower()
    user = (
        db.query(UserModel)
        .filter(UserModel.email == normalized_email)
        .first()
    )
    if user is None:
        return None
    is_valid = password_hash.verify(password, user.hashed_password)
    if not is_valid:
        return None
    token = create_access_token(user.id)

    return {
        "access_token": token,
        "token_type": "bearer",
    }


def get_all_users(current_user: UserModel, db: Session):
    return (
        db.query(UserModel)
        .filter(UserModel.id != current_user.id)
        .filter(UserModel.email != "testuser123@example.com")
        .filter(UserModel.full_name != "Test User")
        .order_by(UserModel.full_name.asc())
        .all()
    )


def update_user_profile(
    current_user: UserModel, data: UserUpdate, db: Session
) -> tuple[UserModel | None, str | None]:
    if data.email is not None:
        normalized_email = data.email.strip().lower()
        existing = (
            db.query(UserModel)
            .filter(
                UserModel.email == normalized_email,
                UserModel.id != current_user.id,
            )
            .first()
        )
        if existing:
            return None, "Email already registered"
        current_user.email = normalized_email

    if data.full_name is not None:
        trimmed = data.full_name.strip()
        if len(trimmed) < 2:
            return None, "Name must be at least 2 characters"
        current_user.full_name = trimmed

    if data.about is not None:
        current_user.about = data.about.strip() or "Available"

    db.commit()
    db.refresh(current_user)
    return current_user, None
