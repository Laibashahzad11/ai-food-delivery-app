"""
app.py
Flask REST API for Khana e Khaana AI Recommendation System
Connects Flutter app to AI engine
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import sys
import os
import socket
from firebase_admin import firestore

# Add parent directory to path to import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from recommendation_engine import KhanaEKhaanaRecommendationEngine
from query_parser import QueryParser

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter to access

# Configure folder for local image storage
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Global variables for AI engine and parser
engine = None
parser = None

def initialize_ai():
    """Initialize AI components"""
    global engine, parser
    
    print("=" * 70)
    print("Starting Khana e Khaana API Server")
    print("=" * 70)
    
    try:
        # Get absolute path to service account key in the current folder
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        service_account_path = os.path.join(base_dir, 'service-account.json')
        
        print(f"\nLoading AI engine with key: {service_account_path}")
        engine = KhanaEKhaanaRecommendationEngine(service_account_path=service_account_path)
        
        print("\nLoading query parser...")
        parser = QueryParser()
        
        print("\nAI components loaded successfully!")
        return True
    except Exception as e:
        print(f"\nError loading AI components: {e}")
        return False

def report_backend_url():
    """Detect local IP and report it to Firestore for dynamic discovery"""
    try:
        # Detect local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            # doesn't even have to be reachable
            s.connect(('10.255.255.255', 1))
            local_ip = s.getsockname()[0]
        except Exception:
            local_ip = '127.0.0.1'
        finally:
            s.close()

        port = int(os.environ.get('PORT', 5000))
        backend_url = f"http://{local_ip}:{port}"
        
        if engine and engine.db:
            engine.db.collection('system_config').document('backend_api').set({
                'baseUrl': backend_url,
                'updated_at': firestore.firestore.SERVER_TIMESTAMP,
                'host_name': "LAIBA SHAHZAD"
            })
            print(f"\nSUCCESS: AI Backend IP reported to Firestore: {backend_url}")
        else:
            print("\nWARNING: Could not report IP - Firestore not initialized")
            
    except Exception as e:
        print(f"\nError reporting IP to Firestore: {e}")

# Initialize on startup
if initialize_ai():
    report_backend_url()

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.route('/', methods=['GET'])
def home():
    """API home - information about endpoints"""
    return jsonify({
        'success': True,
        'message': 'Khana e Khaana AI Recommendation API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'GET /': 'API information',
            'GET /health': 'Health check',
            'POST /recommend': 'Get food recommendations',
            'POST /similar': 'Get similar restaurants',
            'GET /top-rated': 'Get top-rated restaurants',
            'GET /stats': 'Get system statistics'
        },
        'example_request': {
            'endpoint': '/recommend',
            'method': 'POST',
            'body': {
                'query': 'biryani in Lahore',
                'user_location': 'Lahore',
                'top_n': 5
            }
        }
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    is_healthy = engine is not None and parser is not None
    total_products = len(engine.products_df) if engine else 0
    cities = []
    if engine and not engine.products_df.empty and 'city' in engine.products_df.columns:
        cities = list(engine.products_df['city'].unique())
    
    return jsonify({
        'success': True,
        'status': 'healthy' if is_healthy else 'unhealthy',
        'ai_engine': 'loaded' if engine else 'not loaded',
        'query_parser': 'loaded' if parser else 'not loaded',
        'total_products': total_products,
        'cities': cities
    })

@app.route('/recommend', methods=['POST'])
def get_recommendations():
    """
    Main recommendation endpoint
    
    Request body:
    {
        "query": "cheap biryani in Lahore",
        "user_location": "Lahore",  // optional
        "min_rating": 4.0,  // optional
        "price_category": "low",  // optional: low, medium, high
        "top_n": 5  // optional, default 5
    }
    
    Response:
    {
        "success": true,
        "query": "cheap biryani in Lahore",
        "parsed_query": {...},
        "recommendations": [...],
        "count": 5
    }
    """
    try:
        # Check if engine is loaded
        if not engine or not parser:
            return jsonify({
                'success': False,
                'error': 'AI engine not initialized'
            }), 500
        
        # Get request data
        data = request.json
        
        if not data or 'query' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing query parameter'
            }), 400
        
        user_query = data.get('query', '')
        user_location = data.get('user_location', None)
        min_rating = data.get('min_rating', None)
        price_category = data.get('price_category', None)
        top_n = data.get('top_n', 5)
        
        print(f"\n[REQUEST] /recommend | Query: '{user_query}' | PriceCat: {price_category} | Rating: {min_rating}")
        
        # Parse the query
        parsed = parser.parse(user_query)
        
        # Use parsed city or user_location
        city = parsed['city'] or user_location
        
        # Use parsed filters or request filters
        final_min_rating = parsed['min_rating'] or min_rating
        final_price = parsed['price_category'] or price_category
        
        # Get recommendations from AI
        result = engine.recommend_by_query(
            query_text=user_query,
            city=city,
            min_rating=final_min_rating,
            price_category=final_price,
            top_n=top_n
        )
        
        # Add parsed query info
        result['parsed_query'] = {
            'dish': parsed['dish'],
            'city': parsed['city'],
            'price': parsed['price_category'],
            'min_rating': parsed['min_rating']
        }
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/similar', methods=['POST'])
def get_similar():
    """
    Get similar restaurants
    
    Request body:
    {
        "restaurant_name": "Bundu Khan",
        "top_n": 5
    }
    
    Response:
    {
        "success": true,
        "based_on": {...},
        "recommendations": [...]
    }
    """
    try:
        if not engine:
            return jsonify({
                'success': False,
                'error': 'AI engine not initialized'
            }), 500
        
        data = request.json
        
        if not data or 'restaurant_name' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing restaurant_name parameter'
            }), 400
        
        restaurant_name = data.get('restaurant_name', '')
        top_n = data.get('top_n', 5)
        
        # Get similar restaurants
        result = engine.recommend_similar(restaurant_name, top_n=top_n)
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/top-rated', methods=['GET'])
def get_top_rated():
    """
    Get top-rated restaurants
    
    Query parameters:
    - city: Filter by city (optional)
    - cuisine: Filter by cuisine (optional)
    - limit: Number of results (default 10)
    
    Example: /top-rated?city=Lahore&cuisine=Pakistani&limit=5
    """
    try:
        if not engine:
            return jsonify({
                'success': False,
                'error': 'AI engine not initialized'
            }), 500
        
        city = request.args.get('city', None)
        cuisine = request.args.get('cuisine', None)
        limit = int(request.args.get('limit', 10))
        
        result = engine.get_top_rated(
            city=city,
            cuisine=cuisine,
            top_n=limit
        )
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/stats', methods=['GET'])
def get_stats():
    """Get system statistics"""
    try:
        if not engine:
            return jsonify({
                'success': False,
                'error': 'AI engine not initialized'
            }), 500
        
        df = engine.df
        
        stats = {
            'success': True,
            'total_restaurants': len(df),
            'cities': {
                'count': df['city'].nunique(),
                'list': df['city'].value_counts().to_dict()
            },
            'cuisines': {
                'count': df['cuisines'].nunique(),
                'top_10': df['cuisines'].value_counts().head(10).to_dict()
            },
            'ratings': {
                'average': float(df['rating'].mean()),
                'min': float(df['rating'].min()),
                'max': float(df['rating'].max())
            },
            'categories': {
                'pakistani': int(df['is_pakistani'].sum()),
                'fast_food': int(df['is_fastfood'].sum())
            },
            'price_distribution': df['price_category'].value_counts().to_dict()
        }
        
        return jsonify(stats)
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ============================================================================
# IMAGE UPLOAD & SERVING
# ============================================================================

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle image uploads from Flutter"""
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No file part'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'No selected file'}), 400

        # Save file with its original name (or a unique one)
        # Using a subfolder structure if needed
        filename = file.filename
        save_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        
        # Ensure subdirectory exists if filename contains paths
        if '/' in filename or '\\' in filename:
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            
        file.save(save_path)
        
        # Return the local URL for retrieval
        # In a real scenario, use the server's IP, but we'll build it in Flutter
        return jsonify({
            'success': True,
            'message': 'File uploaded successfully',
            'filename': filename,
            'local_path': f'/images/{filename}'
        })
    except Exception as e:
        print(f"Upload Error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/images/<path:filename>', methods=['GET'])
def serve_image(filename):
    """Serve uploaded images"""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.route('/sync', methods=['POST'])
def sync_data():
    """
    Sync live data from Firestore to the AI Engine
    
    Request body:
    {
        "products": [...]
    }
    """
    try:
        global engine
        if not engine:
            return jsonify({
                'success': False,
                'error': 'AI engine not initialized'
            }), 500
            
        data = request.json
        if not data or 'products' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing products in request body'
            }), 400
            
        products = data.get('products', [])
        
        # Synchronize engine with live products
        engine.sync_from_live_data(products)
        
        return jsonify({
            'success': True,
            'message': f'AI Engine successfully synced with {len(products)} products',
            'count': len(products)
        })
        
    except Exception as e:
        print(f"Sync Error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/rate', methods=['POST'])
def submit_rating():
    """
    Submit a user review/rating for a food item.
    Recalculates average rating (integer 1-5) and updates Firestore + AI engine.

    Request body:
    {
        "product_id": "abc123",
        "rating": 4        // integer 1-5
    }
    """
    try:
        if not engine:
            return jsonify({'success': False, 'error': 'AI engine not initialized'}), 500

        data = request.json
        if not data or 'product_id' not in data or 'rating' not in data:
            return jsonify({'success': False, 'error': 'Missing product_id or rating'}), 400

        product_id = data['product_id']
        rating = int(data['rating'])

        if rating < 1 or rating > 5:
            return jsonify({'success': False, 'error': 'Rating must be between 1 and 5'}), 400

        success = engine.update_product_rating(product_id, rating)
        if success:
            return jsonify({
                'success': True,
                'message': f'Rating submitted successfully. Product {product_id} updated.'
            })
        else:
            return jsonify({'success': False, 'error': 'Product not found'}), 404

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500



@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500

# ============================================================================
# RUN SERVER
# ============================================================================

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print("\n" + "=" * 70)
    print("KHANA E KHAANA API SERVER")
    print("=" * 70)
    print(f"Server running on port: {port}")
    print(f"Health Check: http://localhost:{port}/health")
    print("=" * 70)
    print("\nPress Ctrl+C to stop the server")
    print("\nYour Flutter app can now connect to this API!\n")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=False
    )
