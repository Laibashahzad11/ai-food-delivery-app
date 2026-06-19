"""
query_parser.py
Smart query parser for Khana e Khaana
Understands natural language queries like "cheap biryani in Lahore"
"""

import re

class QueryParser:
    """
    Parse user queries to extract intent, location, dish, price preferences
    """
    
    def __init__(self):
        # Pakistani cities
        self.cities = [
            'lahore', 'karachi', 'islamabad', 'rawalpindi', 
            'faisalabad', 'multan', 'peshawar', 'quetta',
            'gujranwala', 'sialkot', 'hyderabad', 'sargodha'
        ]
        
        # Price keywords
        self.price_keywords = {
            'cheap': 'low',
            'affordable': 'low',
            'budget': 'low',
            'inexpensive': 'low',
            'economical': 'low',
            'sasta': 'low',  # Urdu
            'mehnga': 'high',  # Urdu
            'expensive': 'high',
            'premium': 'high',
            'luxury': 'high',
            'costly': 'high',
            'high-end': 'high',
            'top': 'high',
            'best': 'high'
        }
        
        # Dish/cuisine keywords (Pakistani-focused)
        self.dishes = [
            # Pakistani dishes
            'biryani', 'nihari', 'haleem', 'karahi', 'tikka',
            'bbq', 'tandoor', 'kabab', 'kebab', 'pulao',
            'korma', 'sajji', 'chapli', 'seekh', 'paya',
            'halwa puri', 'chana', 'aloo gosht', 'keema',
            'mutton kabab', 'chicken kabab', 'malai boti',
            'paratha roll', 'naan', 'daal', 'sabzi', 'zarda',
            'kheer', 'lassi', 'gol gappay', 'chaat',
            
            # International
            'pizza', 'burger', 'shawarma', 'chinese', 'pasta', 'macaroni', 'macaronies',
            'spaghetti', 'chowmein', 'shashlik', 'sandwich', 'fries', 'wings', 'sushi', 
            'noodles', 'steak', 'platter', 'dessert', 'rolls', 'wrap', 'wraps',
            
            # Categories
            'desi', 'pakistani', 'fast food', 'continental', 'street food'
        ]
        
        # Semantic vibe mapping
        self.vibe_mappings = {
            'healthy': ['salad', 'grilled', 'juice', 'low-fat', 'fruit', 'vegetable', 'diet', 'boiled'],
            'light': ['soup', 'sandwich', 'salad', 'snack', 'tea', 'biscuit'],
            'heavy': ['nihari', 'paya', 'burger', 'platter', 'karahi', 'mutton', 'beef', 'steak'],
            'party': ['pizza', 'wings', 'platter', 'coke', 'fries', 'cake', 'deal'],
            'quick': ['burger', 'shawarma', 'sandwich', 'fries', 'wings', 'roll'],
            'spice': ['tikka', 'karahi', 'chutney', 'biryani', 'masala', 'chilli'],
            'sweet': ['dessert', 'cake', 'halwa', 'zarda', 'kheer', 'ice cream', 'shake']
        }
    
    def parse(self, query):
        """
        Parse user query and extract structured information
        
        Args:
            query: User's search query string
            
        Returns:
            Dict with extracted information
        """
        query_lower = query.lower()
        
        result = {
            'original_query': query,
            'city': None,
            'dish': None,
            'price_category': None,
            'min_rating': None,
            'vibes': [],
            'keywords': []
        }
        
        # Extract city
        for city in self.cities:
            if city in query_lower:
                result['city'] = city.title()
                break
        
        # Handle "near me" or "nearby"
        if 'near me' in query_lower or 'nearby' in query_lower:
            result['nearby'] = True
        
        # Extract price preference
        for keyword, category in self.price_keywords.items():
            if keyword in query_lower:
                result['price_category'] = category
                break
        
        # Extract vibes
        for vibe, associated_keywords in self.vibe_mappings.items():
            if vibe in query_lower:
                result['vibes'].append(vibe)
                result['keywords'].extend(associated_keywords)
        
        # Special time-of-day intent
        if 'dinner' in query_lower or 'night' in query_lower:
            result['vibes'].append('heavy')
            result['keywords'].extend(['main course', 'platter', 'karahi'])
        elif 'breakfast' in query_lower or 'morning' in query_lower:
            result['vibes'].append('light')
            result['keywords'].extend(['paratha', 'halwa puri', 'egg', 'tea'])
        elif 'lunch' in query_lower:
            result['vibes'].append('quick')
            result['keywords'].extend(['burger', 'biryani', 'deal'])

        # Extract dish/cuisine
        dishes_found = []
        for dish in self.dishes:
            if dish in query_lower:
                dishes_found.append(dish)
        
        if dishes_found:
            result['dish'] = dishes_found[0]  # Take first match
            result['all_dishes'] = dishes_found
        
        # Extract rating requirement
        rating_patterns = [
            r'(\d+(?:\.\d+)?)\s*(?:star|rating|\+|stars)',
            r'rated?\s*(\d+(?:\.\d+)?)',
            r'above\s*(\d+(?:\.\d+)?)',
            r'minimum\s*(\d+(?:\.\d+)?)'
        ]
        
        for pattern in rating_patterns:
            match = re.search(pattern, query_lower)
            if match:
                try:
                    rating = float(match.group(1))
                    if 0 <= rating <= 5:
                        result['min_rating'] = rating
                        break
                except:
                    pass
        
        # Extract other keywords
        # Remove common words and phrases
        stop_words = {'the', 'a', 'an', 'in', 'at', 'for', 'to', 'of', 
                      'show', 'find', 'get', 'want', 'hungry', 'food', 'something', 'give', 'me', 'please', 
                      'tell', 'suggest', 'was', 'were', 'had', 'can', 'you', 'u', 'i', 'is', 'am',
                      'recommend', 'some', 'eat', 'hey', 'hello', 'suggest me', 'give me'}
        
        words = query_lower.split()
        keywords = [w for w in words if w not in stop_words and len(w) > 2]
        
        # Avoid duplicate keywords already in result
        existing = []
        if result['city']: existing.append(result['city'].lower())
        if result['dish']: existing.append(result['dish'].lower())
        
        final_keywords = []
        for kw in keywords:
            is_new = True
            for ex in existing:
                if ex in kw or kw in ex:
                    is_new = False
                    break
            if is_new:
                final_keywords.append(kw)
                
        result['keywords'] = final_keywords[:5]  # Top 5 keywords
        
        return result
    
    def build_search_query(self, parsed):
        """
        Build optimized search query for the AI engine
        
        Args:
            parsed: Parsed query dict
            
        Returns:
            String search query
        """
        parts = []
        
        # Add dish/cuisine (most important)
        if parsed['dish']:
            parts.append(parsed['dish'])
        
        # Add city
        if parsed['city']:
            parts.append(parsed['city'])
        
        # Add other keywords
        if not parts and parsed['keywords']:
            parts.extend(parsed['keywords'][:3])
        
        # If nothing found, use original query
        if not parts:
            parts.append(parsed['original_query'])
        
        return ' '.join(parts)
    
    def get_filters(self, parsed):
        """
        Extract filters for the recommendation engine
        
        Args:
            parsed: Parsed query dict
            
        Returns:
            Dict with filters
        """
        filters = {}
        
        if parsed['city']:
            filters['city'] = parsed['city']
        
        if parsed['price_category']:
            filters['price_category'] = parsed['price_category']
        
        if parsed['min_rating']:
            filters['min_rating'] = parsed['min_rating']
        
        return filters


# ============================================================================
# TESTING
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("🧪 TESTING QUERY PARSER")
    print("=" * 70)
    
    parser = QueryParser()
    
    test_queries = [
        "cheap biryani in Lahore",
        "best BBQ restaurant Karachi",
        "affordable pizza near me",
        "nihari in Rawalpindi rated above 4",
        "premium dining Islamabad",
        "budget shawarma 4.5 star",
        "fast food Faisalabad",
        "Pakistani food Lahore minimum 4 rating",
        "show me tikka restaurants",
        "sasta Chinese food Karachi"
    ]
    
    print("\n" + "=" * 70)
    print("Testing Pakistani Food Queries")
    print("=" * 70)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n{i}. Query: '{query}'")
        print("   " + "-" * 60)
        
        # Parse the query
        result = parser.parse(query)
        
        print(f"   City:          {result['city']}")
        print(f"   Dish:          {result['dish']}")
        print(f"   Price:         {result['price_category']}")
        print(f"   Min Rating:    {result['min_rating']}")
        print(f"   Keywords:      {result['keywords']}")
        
        # Build search query
        search_query = parser.build_search_query(result)
        print(f"   Search Query:  {search_query}")
        
        # Get filters
        filters = parser.get_filters(result)
        print(f"   Filters:       {filters}")
    
    print("\n" + "=" * 70)
    print("✅ QUERY PARSER TEST COMPLETE")
    print("=" * 70)