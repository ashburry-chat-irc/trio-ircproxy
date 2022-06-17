from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from sqlalchemy.sql import func

db = SQLAlchemy()


class User(db.Model, UserMixin):
    """database object to define users and their passwords with flask_login"""
    id: db.Column = db.Column(db.Integer, primary_key=True)
    user_name: db.Column = db.Column(db.String(150), unique=True)
    email: db.Column = db.Column(db.String(150))
    password: db.Column = db.Column(db.String(150))
    type: db.Column = db.Column(db.String(30))
    ip: db.Column = db.Column(db.String(150))
    notes: db.relationship = db.relationship('Note')


class Note(db.Model):
    """Implemented with Javascript to add notes to the database"""
    id: db.Column = db.Column(db.Integer, primary_key=True)
    data: db.Column = db.Column(db.String(10000))
    date: db.Column = db.Column(db.DateTime(timezone=True), default=func.now())
    user_id: db.Column = db.Column(db.Integer, db.ForeignKey('user.id'))


