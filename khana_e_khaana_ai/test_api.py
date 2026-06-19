"""
test_api.py
FastAPI Application for Khana e Khaana Food Recommendation System
Test with: uvicorn test_api:app --reload
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import uvicorn

# Your custom modules
from recommendation_engine import KhanaEKhaanaRecommendationEngine
from query_parser import QueryParser

# ============================================================================
# INITIALIZE APP
# ============================================================================

app = FastAPI(
    title="Khana e Khaana API",
    description="AI-Powered Food Recommendation System for Pakistan",
    version="1.0.0",
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc"  # ReDoc
)

# Enable CORS (for frontend development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize AI engine and parser (loaded once at startup)
engine = None
parser = QueryParser()

# ============================================================================
# PYDANTIC MODELS (Request/Response Schemas)
# ============================================================================

class SearchRequest(BaseModel):
    """Request model for natural language search"""
    query: str = Field(..., description="User's search query", example="cheap biryani in Lahore")
    top_n: Optional[int] = Field(5, description="Number of recommendations", ge=1, le=20)

class RestaurantRecommendation(BaseModel):
    """Model for a single restaurant recommendation"""
    restaurant_name: str
    city: str
    cuisines: str
    rating: float
    reviews_count: int
    price_category: str
    match_score: Optional[float] = None
    similarity_score: Optional[float] = None

class RecommendationResponse(BaseModel):
    """Response model for recommendations"""
    success: bool
    type: str
    total_found: int
    showing: int
    recommendations: List[Dict[str, Any]]
    filters_applied: Optional[Dict[str, Any]] = None

class SimilarRequest(BaseModel):
    """Request model for similar restaurant search"""
    restaurant_name: str = Field(..., description="Name of restaurant", example="Bundoo Khan")
    top_n: Optional[int] = Field(5, description="Number of recommendations", ge=1, le=20)

class TopRatedRequest(BaseModel):
    """Request model for top-rated restaurants"""
    city: Optional[str] = Field(None, description="Filter by city", example="Lahore")
    cuisine: Optional[str] = Field(None, description="Filter by cuisine", example="Pakistani")
    top_n: Optional[int] = Field(10, description="Number of results", ge=1, le=50)

class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    message: str
    restaurants_loaded: int
    cities_available: List[str]

# ============================================================================
# STARTUP/SHUTDOWN EVENTS
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Initialize the AI engine when the API starts"""
    global engine
    print("\n" + "=" * 70)
    print("Starting Khana e Khaana API")
    print("=" * 70)
    
    try:
        # Initialize recommendation engine
        engine = KhanaEKhaanaRecommendationEngine(
            data_path='data/pakistan_foodpanda_cleaned.csv'
        )
        print("API Ready to serve recommendations!")
        print("=" * 70)
    except Exception as e:
        print(f"Error initializing engine: {e}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup when the API shuts down"""
    print("\n👋 Shutting down Khana e Khaana API")

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/", tags=["General"])
async def root():
    """Root endpoint - API information"""
    return {
        "message": "Welcome to Khana e Khaana API",
        "version": "1.0.0",
        "description": "AI-Powered Food Recommendation System for Pakistan",
        "documentation": {
            "swagger_ui": "/docs",
            "redoc": "/redoc"
        },
        "endpoints": {
            "health": "/health",
            "search": "/search",
            "similar": "/similar",
            "top_rated": "/top-rated",
            "cities": "/cities",
            "cuisines": "/cuisines"
        }
    }

@app.get("/health", response_model=HealthResponse, tags=["General"])
async def health_check():
    """Check if the API is running and the AI engine is loaded"""
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    return HealthResponse(
        status="healthy",
        message="Khana e Khaana API is running smoothly",
        restaurants_loaded=len(engine.df),
        cities_available=engine.df['city'].unique().tolist()
    )

@app.post("/search", tags=["Recommendations"])
async def search_restaurants(request: SearchRequest):
    """
    🔍 Smart Search - Natural Language Query
    
    Examples:
    - "cheap biryani in Lahore"
    - "best BBQ in Karachi rated above 4"
    - "affordable pizza near me"
    - "Pakistani food Islamabad minimum 4 rating"
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        # Parse the query
        parsed = parser.parse(request.query)
        
        # Build search query
        search_query = parser.build_search_query(parsed)
        
        # Get filters
        filters = parser.get_filters(parsed)
        
        # Get recommendations
        result = engine.recommend_by_query(
            query_text=search_query,
            city=filters.get('city'),
            min_rating=filters.get('min_rating'),
            price_category=filters.get('price_category'),
            top_n=request.top_n
        )
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@app.get("/search-simple", tags=["Recommendations"])
async def search_simple(
    query: str = Query(..., description="Search query", example="biryani"),
    city: Optional[str] = Query(None, description="Filter by city", example="Lahore"),
    min_rating: Optional[float] = Query(None, description="Minimum rating", ge=0, le=5),
    price_category: Optional[str] = Query(None, description="Price category (low/medium/high)"),
    top_n: int = Query(5, description="Number of results", ge=1, le=20)
):
    """
    🔍 Simple Search - Direct Parameters
    
    Use this endpoint if you want to provide filters directly without natural language parsing.
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        result = engine.recommend_by_query(
            query_text=query,
            city=city,
            min_rating=min_rating,
            price_category=price_category,
            top_n=top_n
        )
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@app.post("/similar", tags=["Recommendations"])
async def find_similar_restaurants(request: SimilarRequest):
    """
    🎯 Find Similar Restaurants
    
    Get restaurants similar to a specific restaurant based on:
    - Cuisine type
    - Location
    - Price range
    - Customer ratings
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        result = engine.recommend_similar(
            restaurant_name=request.restaurant_name,
            top_n=request.top_n
        )
        
        if not result['success']:
            raise HTTPException(status_code=404, detail=result['message'])
        
        return result
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Similar search failed: {str(e)}")

@app.get("/similar-simple", tags=["Recommendations"])
async def find_similar_simple(
    restaurant_name: str = Query(..., description="Restaurant name", example="Bundoo Khan"),
    top_n: int = Query(5, description="Number of results", ge=1, le=20)
):
    """
    🎯 Find Similar Restaurants - Simple GET Version
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        result = engine.recommend_similar(
            restaurant_name=restaurant_name,
            top_n=top_n
        )
        
        if not result['success']:
            raise HTTPException(status_code=404, detail=result['message'])
        
        return result
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Similar search failed: {str(e)}")

@app.post("/top-rated", tags=["Recommendations"])
async def get_top_rated(request: TopRatedRequest):
    """
    🏆 Get Top-Rated Restaurants
    
    Filter by:
    - City (optional)
    - Cuisine type (optional)
    - Number of results
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        result = engine.get_top_rated(
            city=request.city,
            cuisine=request.cuisine,
            top_n=request.top_n
        )
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Top rated query failed: {str(e)}")

@app.get("/top-rated-simple", tags=["Recommendations"])
async def get_top_rated_simple(
    city: Optional[str] = Query(None, description="Filter by city", example="Karachi"),
    cuisine: Optional[str] = Query(None, description="Filter by cuisine", example="Pakistani"),
    top_n: int = Query(10, description="Number of results", ge=1, le=50)
):
    """
    🏆 Get Top-Rated Restaurants - Simple GET Version
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    try:
        result = engine.get_top_rated(
            city=city,
            cuisine=cuisine,
            top_n=top_n
        )
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Top rated query failed: {str(e)}")

@app.get("/cities", tags=["Data"])
async def get_cities():
    """
    📍 Get All Available Cities
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    cities = sorted(engine.df['city'].unique().tolist())
    
    return {
        "success": True,
        "total": len(cities),
        "cities": cities
    }

@app.get("/cuisines", tags=["Data"])
async def get_cuisines():
    """
    🍽️ Get All Available Cuisines
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    # Extract unique cuisines
    all_cuisines = set()
    for cuisines_str in engine.df['cuisines'].dropna():
        for cuisine in str(cuisines_str).split(','):
            all_cuisines.add(cuisine.strip())
    
    cuisines = sorted(list(all_cuisines))
    
    return {
        "success": True,
        "total": len(cuisines),
        "cuisines": cuisines
    }

@app.get("/stats", tags=["Data"])
async def get_statistics():
    """
    📊 Get Dataset Statistics
    """
    if engine is None:
        raise HTTPException(status_code=503, detail="AI Engine not initialized")
    
    return {
        "success": True,
        "statistics": {
            "total_restaurants": len(engine.df),
            "cities": len(engine.df['city'].unique()),
            "avg_rating": round(engine.df['rating'].mean(), 2),
            "total_reviews": int(engine.df['reviews_count'].sum()),
            "price_distribution": engine.df['price_category'].value_counts().to_dict()
        }
    }

# ============================================================================
# RUN THE APP
# ============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("Starting Khana e Khaana FastAPI Server")
    print("=" * 70)
    print("\nServer will be available at:")
    print("  Local: http://127.0.0.1:8000")
    print("  Swagger UI: http://127.0.0.1:8000/docs")
    print("  ReDoc: http://127.0.0.1:8000/redoc")
    print("\nPress CTRL+C to stop the server")
    print("=" * 70 + "\n")
    
    uvicorn.run(
        "test_api:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Auto-reload on code changes
        log_level="info"
    )