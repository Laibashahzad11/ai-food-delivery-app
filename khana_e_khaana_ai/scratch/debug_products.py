
from firebase_admin import credentials, firestore, initialize_app
import os

# Get absolute path to service account key (one level up from scratch)
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
service_account_path = os.path.join(base_dir, 'service-account.json')

if not os.path.exists(service_account_path):
    print(f"Error: {service_account_path} not found")
    exit(1)

# Initialize Firebase
cred = credentials.Certificate(service_account_path)
try:
    initialize_app(cred)
except:
    pass # Already initialized

db = firestore.client()

print("Fetching products from Firestore...")
products = db.collection('products').get()

print(f"\nFound {len(products)} products:")
for doc in products:
    data = doc.to_dict()
    name = data.get('productName', 'Unknown')
    price = data.get('productPrice', 0)
    rating = data.get('averageRating', 0)
    available = data.get('isAvailable', True)
    print(f"- {name} (Rs. {price}) | Rating: {rating} | Available: {available}")
