from datetime import datetime

from app import db


class Restaurant(db.Model):
    __tablename__ = "restaurants"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text)
    category = db.Column(db.String(80))
    rating = db.Column(db.Float, default=0.0)
    delivery_time = db.Column(db.String(50))
    image = db.Column(db.String(255))
    available = db.Column(db.Boolean, default=True)

    products = db.relationship(
        "Product", backref="restaurant", lazy=True, cascade="all, delete-orphan"
    )

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "category": self.category,
            "rating": self.rating,
            "delivery_time": self.delivery_time,
            "image": self.image,
            "available": self.available,
        }


class Category(db.Model):
    __tablename__ = "categories"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False, unique=True)
    image = db.Column(db.String(255))

    products = db.relationship("Product", backref="category", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "image": self.image,
        }


class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text)
    price = db.Column(db.Integer, nullable=False)
    image = db.Column(db.String(255))
    available = db.Column(db.Boolean, default=True)

    restaurant_id = db.Column(
        db.Integer, db.ForeignKey("restaurants.id"), nullable=False
    )

    category_id = db.Column(db.Integer, db.ForeignKey("categories.id"), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "price": self.price,
            "image": self.image,
            "available": self.available,
            "restaurant_id": self.restaurant_id,
            "category_id": self.category_id,
        }


class Order(db.Model):
    __tablename__ = "orders"

    id = db.Column(db.Integer, primary_key=True)

    restaurant_id = db.Column(
        db.Integer, db.ForeignKey("restaurants.id"), nullable=False
    )

    subtotal = db.Column(db.Integer, nullable=False)
    delivery = db.Column(db.Integer, nullable=False)
    total = db.Column(db.Integer, nullable=False)

    status = db.Column(db.String(50), nullable=False, default="pending")
    delivery_address = db.Column(db.String(255), nullable=False, default="")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    items = db.relationship(
        "OrderItem", backref="order", lazy=True, cascade="all, delete-orphan"
    )


class OrderItem(db.Model):
    __tablename__ = "order_items"

    id = db.Column(db.Integer, primary_key=True)

    order_id = db.Column(db.Integer, db.ForeignKey("orders.id"), nullable=False)

    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), nullable=False)

    quantity = db.Column(db.Integer, nullable=False)

    price = db.Column(db.Integer, nullable=False)
