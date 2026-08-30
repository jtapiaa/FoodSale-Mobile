from flask import Blueprint, jsonify, request
from app.models import Product, Restaurant, Category, Order, OrderItem

main = Blueprint("main", __name__)


@main.route("/")
def home():
    return jsonify(
        {
            "app": "FoodSale API",
            "status": "ok",
            "message": "Backend funcionando correctamente",
        }
    )


@main.route("/api/restaurants", methods=["GET"])
def get_restaurants():
    restaurants = Restaurant.query.all()

    return jsonify([restaurant.to_dict() for restaurant in restaurants])


@main.route("/api/restaurants", methods=["POST"])
def create_restaurant():
    from app import db

    data = request.get_json()

    restaurant = Restaurant(
        name=data["name"],
        description=data.get("description"),
        category=data.get("category"),
        rating=data.get("rating", 0.0),
        delivery_time=data.get("delivery_time"),
        image=data.get("image"),
        available=data.get("available", True),
    )

    db.session.add(restaurant)
    db.session.commit()

    return jsonify(restaurant.to_dict()), 201


@main.route("/api/categories", methods=["GET"])
def get_categories():
    categories = Category.query.all()
    return jsonify([category.to_dict() for category in categories])


@main.route("/api/categories", methods=["POST"])
def create_category():
    from app import db

    data = request.get_json()
    category = Category(name=data["name"], image=data.get("image"))
    db.session.add(category)
    db.session.commit()
    return jsonify(category.to_dict()), 201


@main.route("/api/products", methods=["GET"])
def get_products():
    products = Product.query.all()
    return jsonify([product.to_dict() for product in products])


@main.route("/api/restaurants/<int:restaurant_id>/products", methods=["GET"])
def get_restaurant_products(restaurant_id):
    products = Product.query.filter_by(restaurant_id=restaurant_id).all()

    return jsonify([product.to_dict() for product in products])


@main.route("/api/products", methods=["POST"])
def create_product():
    from app import db

    data = request.get_json()
    product = Product(
        name=data["name"],
        description=data.get("description"),
        price=data["price"],
        image=data.get("image"),
        available=data.get("available", True),
        restaurant_id=data["restaurant_id"],
        category_id=data["category_id"],
    )
    db.session.add(product)
    db.session.commit()
    return jsonify(product.to_dict()), 201


@main.route("/api/orders", methods=["POST"])
def create_order():
    from app import db

    data = request.get_json()

    restaurant_id = data["restaurant_id"]
    items = data["items"]

    delivery = data.get("delivery", 1990)

    subtotal = 0

    order = Order(
        restaurant_id=restaurant_id,
        subtotal=0,
        delivery=delivery,
        total=0,
        status="pending",
    )

    db.session.add(order)

    for item in items:
        product = Product.query.get(item["product_id"])

        if not product:
            return jsonify({"error": f"Producto {item['product_id']} no existe"}), 404

        quantity = item["quantity"]

        item_total = product.price * quantity
        subtotal += item_total

        order_item = OrderItem(
            order=order, product_id=product.id, quantity=quantity, price=product.price
        )

        db.session.add(order_item)

    order.subtotal = subtotal
    order.total = subtotal + delivery

    db.session.commit()

    return (
        jsonify(
            {
                "id": order.id,
                "restaurant_id": order.restaurant_id,
                "subtotal": order.subtotal,
                "delivery": order.delivery,
                "total": order.total,
                "status": order.status,
                "items": [
                    {
                        "product_id": item.product_id,
                        "quantity": item.quantity,
                        "price": item.price,
                    }
                    for item in order.items
                ],
            }
        ),
        201,
    )


@main.route("/api/orders", methods=["GET"])
def get_orders():
    orders = Order.query.order_by(Order.created_at.desc()).all()

    result = []

    for order in orders:
        restaurant = Restaurant.query.get(order.restaurant_id)

        result.append(
            {
                "id": order.id,
                "restaurant_id": order.restaurant_id,
                "restaurant_name": restaurant.name if restaurant else "Restaurante",
                "subtotal": order.subtotal,
                "delivery": order.delivery,
                "total": order.total,
                "status": order.status,
                "created_at": order.created_at.isoformat(),
                "items": [
                    {
                        "product_id": item.product_id,
                        "product_name": (
                            Product.query.get(item.product_id).name
                            if Product.query.get(item.product_id)
                            else "Producto"
                        ),
                        "quantity": item.quantity,
                        "price": item.price,
                    }
                    for item in order.items
                ],
            }
        )

    return jsonify(result)


@main.route("/api/search", methods=["GET"])
def search():
    query = request.args.get("q", "").strip()

    if not query:
        return jsonify([])

    products = Product.query.filter(Product.name.ilike(f"%{query}%")).all()

    result = []

    for product in products:
        restaurant = Restaurant.query.get(product.restaurant_id)

        result.append(
            {
                "id": product.id,
                "name": product.name,
                "description": product.description,
                "price": product.price,
                "image": product.image,
                "available": product.available,
                "restaurant_id": product.restaurant_id,
                "restaurant_name": (restaurant.name if restaurant else "Restaurante"),
                "restaurant_rating": (restaurant.rating if restaurant else 0.0),
                "restaurant_delivery_time": (
                    restaurant.delivery_time if restaurant else ""
                ),
                "restaurant_category": (restaurant.category if restaurant else ""),
            }
        )

    return jsonify(result)
