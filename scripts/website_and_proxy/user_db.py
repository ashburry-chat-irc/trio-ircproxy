from flask_sqlalchemy import SQLAlchemy
from flask import Flask
from flask_login import UserMixin
from sqlalchemy.sql import func

db = SQLAlchemy()
app_new = Flask(__name__)


class User(db.Model, UserMixin):
    id: db.Column = db.Column(db.Integer, primary_key=True)
    email: db.Column = db.Column(db.String(150), unique=True)
    user_name: db.Column = db.Column(db.String(150), unique=True)
    password: db.Column = db.Column(db.String(150))
    type: db.Column = db.Column(db.String(30))
    ip: db.Column = db.Column(db.String(150))
    notes: db.relationship = db.relationship('Note')

class Note(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    data = db.Column(db.String(10000))
    date = db.Column(db.DateTime(timezone=True), default=func.now())
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))


