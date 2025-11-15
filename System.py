from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)

# MySQL Config
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Arusha@14'
app.config['MYSQL_DB'] = 'car_rental'

mysql = MySQL(app)

PRICE_PER_DAY = 50

@app.route('/rent', methods=['POST'])
def rent_car():
    data = request.json
    if not data or 'name' not in data or 'car_model' not in data:
        return jsonify({'error': 'Invalid data'}), 400

    name = data['name']
    car_model = data['car_model']
    rental_date = datetime.strptime(data['rental_date'], '%Y-%m-%d').date()
    return_date = datetime.strptime(data['return_date'], '%Y-%m-%d').date()

    days_rented = (return_date - rental_date).days
    total_amount = days_rented * PRICE_PER_DAY if days_rented > 0 else 0

    try:
        cursor = mysql.connection.cursor()
        cursor.execute(
            'INSERT INTO rentals (name, car_model, rental_date, return_date, total_amount) VALUES (%s, %s, %s, %s, %s)',
            (name, car_model, rental_date, return_date, total_amount)
        )
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'Car rented successfully', 'total_amount': total_amount}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/rentals', methods=['GET'])
def get_rentals():
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM rentals')
    results = cursor.fetchall()

    rentals = [
        {
            'id': r[0], 
            'name': r[1],
            'car_model': r[2],
            'rental_date': str(r[3]),
            'return_date': str(r[4]),
            'total_amount': r[5]
        }
        for r in results
    ]

    cursor.close()
    return jsonify(rentals), 200


@app.route('/rentals/<int:rental_id>', methods=['PUT'])
def update_rental(rental_id):
    data = request.json

    rental_date = datetime.strptime(data['rental_date'], '%Y-%m-%d').date()
    return_date = datetime.strptime(data['return_date'], '%Y-%m-%d').date()

    days_rented = (return_date - rental_date).days
    total_amount = days_rented * PRICE_PER_DAY if days_rented > 0 else 0

    try:
        cursor = mysql.connection.cursor()
        cursor.execute(
            'UPDATE rentals SET rental_date = %s, return_date = %s, total_amount = %s WHERE id = %s',
            (rental_date, return_date, total_amount, rental_id)
        )
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'Rental updated successfully', 'total_amount': total_amount}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/rentals/<int:rental_id>', methods=['DELETE'])
def delete_rental(rental_id):
    try:
        cursor = mysql.connection.cursor()
        cursor.execute('DELETE FROM rentals WHERE id = %s', (rental_id,))
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'Rental deleted successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
