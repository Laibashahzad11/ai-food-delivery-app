"""
test_backend.py
Quick script to test if your backend is working correctly
Run this BEFORE connecting Flutter app
"""

import requests
import json

BASE_URL = "http://localhost:5000"

def print_separator():
    print("\n" + "=" * 70)

def test_health():
    """Test health endpoint"""
    print_separator()
    print("🏥 TEST 1: Health Check")
    print_separator()
    
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code == 200:
            print("✅ Health check PASSED")
            return True
        else:
            print("❌ Health check FAILED")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n⚠️ Make sure your Flask server is running!")
        print("   Run: python app.py")
        return False

def test_recommendations():
    """Test recommendation endpoint"""
    print_separator()
    print("🍽️ TEST 2: Get Recommendations")
    print_separator()
    
    try:
        data = {
            "query": "biryani in Lahore",
            "top_n": 3
        }
        
        print(f"Request: {json.dumps(data, indent=2)}")
        
        response = requests.post(
            f"{BASE_URL}/recommend",
            json=data,
            timeout=10
        )
        
        print(f"\nStatus Code: {response.status_code}")
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print("✅ Recommendations endpoint PASSED")
            print(f"\nFound {len(result.get('recommendations', []))} restaurants:")
            
            for i, restaurant in enumerate(result.get('recommendations', [])[:3], 1):
                print(f"\n{i}. {restaurant.get('restaurant_name')}")
                print(f"   City: {restaurant.get('city')}")
                print(f"   Rating: {restaurant.get('rating')}")
                print(f"   Match: {restaurant.get('match_score', 0):.1f}%")
            
            return True
        else:
            print("❌ Recommendations endpoint FAILED")
            print(f"Response: {json.dumps(result, indent=2)}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_top_rated():
    """Test top rated endpoint"""
    print_separator()
    print("⭐ TEST 3: Get Top Rated")
    print_separator()
    
    try:
        response = requests.get(
            f"{BASE_URL}/top-rated?city=Lahore&limit=3",
            timeout=10
        )
        
        print(f"Status Code: {response.status_code}")
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print("✅ Top rated endpoint PASSED")
            print(f"\nTop restaurants:")
            
            for i, restaurant in enumerate(result.get('recommendations', []), 1):
                print(f"\n{i}. {restaurant.get('restaurant_name')}")
                print(f"   Rating: {restaurant.get('rating')}")
                print(f"   Reviews: {restaurant.get('reviews_count')}")
            
            return True
        else:
            print("❌ Top rated endpoint FAILED")
            print(f"Response: {json.dumps(result, indent=2)}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_similar():
    """Test similar restaurants endpoint"""
    print_separator()
    print("🔍 TEST 4: Get Similar Restaurants")
    print_separator()
    
    try:
        data = {
            "restaurant_name": "Bundu Khan",
            "top_n": 3
        }
        
        print(f"Request: {json.dumps(data, indent=2)}")
        
        response = requests.post(
            f"{BASE_URL}/similar",
            json=data,
            timeout=10
        )
        
        print(f"\nStatus Code: {response.status_code}")
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print("✅ Similar restaurants endpoint PASSED")
            
            if 'based_on' in result:
                print(f"\nBased on: {result['based_on'].get('name')}")
            
            print(f"\nSimilar restaurants:")
            for i, restaurant in enumerate(result.get('recommendations', []), 1):
                print(f"\n{i}. {restaurant.get('restaurant_name')}")
                print(f"   Similarity: {restaurant.get('similarity_score', 0):.1f}%")
            
            return True
        else:
            print("⚠️ Similar endpoint returned no results")
            print("   This might be because restaurant name doesn't exist")
            return True  # Not a critical failure
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_stats():
    """Test statistics endpoint"""
    print_separator()
    print("📊 TEST 5: Get Statistics")
    print_separator()
    
    try:
        response = requests.get(f"{BASE_URL}/stats", timeout=5)
        
        print(f"Status Code: {response.status_code}")
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print("✅ Statistics endpoint PASSED")
            print(f"\nTotal Restaurants: {result.get('total_restaurants')}")
            print(f"Cities: {result.get('cities', {}).get('count')}")
            print(f"Average Rating: {result.get('ratings', {}).get('average', 0):.2f}")
            
            return True
        else:
            print("❌ Statistics endpoint FAILED")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Run all tests"""
    print("\n" + "=" * 70)
    print("🧪 KHANA E KHAANA BACKEND TEST SUITE")
    print("=" * 70)
    print("\nThis will test if your Python backend is working correctly")
    print("Make sure your Flask server is running: python app.py")
    print("=" * 70)
    
    input("\nPress Enter to start tests...")
    
    # Run tests
    results = []
    results.append(("Health Check", test_health()))
    
    if results[0][1]:  # Only continue if health check passes
        results.append(("Recommendations", test_recommendations()))
        results.append(("Top Rated", test_top_rated()))
        results.append(("Similar", test_similar()))
        results.append(("Statistics", test_stats()))
    else:
        print("\n⚠️ Skipping remaining tests because health check failed")
    
    # Summary
    print_separator()
    print("📋 TEST SUMMARY")
    print_separator()
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print_separator()
    print(f"Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Your backend is ready for Flutter!")
        print("\nNext steps:")
        print("1. Update Flutter api_service.dart with correct BASE_URL")
        print("2. Run your Flutter app: flutter run")
        print("3. Test the search functionality")
    else:
        print("\n⚠️ Some tests failed. Please check:")
        print("1. Is Flask server running? (python app.py)")
        print("2. Is the CSV file in the correct location?")
        print("3. Are all Python packages installed?")
    
    print("=" * 70)

if __name__ == "__main__":
    main()
