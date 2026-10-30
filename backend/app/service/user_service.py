from sqlalchemy.orm import Session
from pwdlib import PasswordHash
from ..core.security import create_access_token
from ..model.user_model import UserModel
from ..schema.user_schema import UserCreate

password_hash = PasswordHash.recommended()


def create_user(user: UserCreate, db: Session):
    existing_user = (
        db.query(UserModel)
        .filter(UserModel.email == user.email)
        .first()
    )
    if existing_user:
        return None
    hashed_password = password_hash.hash(user.password)

    new_user = UserModel(
        full_name=user.full_name,
        email=user.email,
        hashed_password=hashed_password
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def login_user(email: str, password: str, db: Session):
    user = (
        db.query(UserModel)
        .filter(UserModel.email == email)
        .first()
    )
    if user is None:
        return None
    is_valid = password_hash.verify(
        password,
        user.hashed_password
    )
    if not is_valid:
        return None
    token = create_access_token(user.id)

    return {
        "access_token": token,
        "token_type": "bearer"
    }
