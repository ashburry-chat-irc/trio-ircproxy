try:
    from circular import User
    from circular import db
except ModuleNotFoundError:
    from .circular import User
    from .circular import db

admin = User.query.filter_by(user_name='admin').first()