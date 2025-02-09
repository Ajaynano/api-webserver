from flask import Flask, jsonify, request
from dotenv import load_dotenv
import requests
import os

load_dotenv('dev.env')
app = Flask(__name__)

# Read environment variables
DUMMY_USER = os.getenv('DUMMY_USER')
DUMMY_PASSWORD = os.getenv('DUMMY_PASSWORD')

# Function to get bearer token
def get_bearer_token():
    url = 'https://dummyjson.com/auth/login'
    payload = {
        'username': DUMMY_USER,
        'password': DUMMY_PASSWORD
    }
    response = requests.post(url, json=payload)
    response_data = response.json()
    return response_data['accessToken']

# Get the bearer token at startup
BEARER_TOKEN = get_bearer_token()
HEADERS = {
    'Authorization': f'Bearer {BEARER_TOKEN}'
}

@app.route('/api/products', methods=['GET'])
def get_products():
    limit = request.args.get('limit', 10)
    skip = request.args.get('skip', 0)
    response = requests.get(f'https://dummyjson.com/products?limit={limit}&skip={skip}', headers=HEADERS)
    products = response.json()
    return jsonify(products)

@app.route('/api/products/<id>', methods=['GET'])
def get_product_by_id(id):
    if not id.isdigit():
        return jsonify({'error': 'Please enter a valid integer'}), 400
    
    response = requests.get(f'https://dummyjson.com/products/{id}', headers=HEADERS)
    product = response.json()
    return jsonify(product)

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)