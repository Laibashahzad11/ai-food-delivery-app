import pandas as pd
import numpy as np
import os
import re
import csv
import random
import firebase_admin
from firebase_admin import credentials, firestore
from query_parser import QueryParser

class KhanaEKhaanaRecommendationEngine:
    """
    AI-powered food recommendation system for Khana e Khaana
    """
    
    def __init__(self, service_account_path='service-account.json'):
        print("Initializing Khana e Khaana AI Recommendation Engine")
        self._init_firebase(service_account_path)
        self.products_df = pd.DataFrame() 
        self.brand_ratings = {}
        self.parser = QueryParser()
        self._load_csv_dataset(os.path.join(os.path.dirname(service_account_path), 'data', 'pakistan_foodpanda_combined.csv'))
        self._load_all_data()

    def _normalize(self, text):
        if not text: return ""
        text = re.sub(r'[^\w\s]', '', text.lower())
        return " ".join(text.split())

    def _load_csv_dataset(self, path):
        if not os.path.exists(path): return
        try:
            with open(path, mode='r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    full_name = row['CompleteStoreName'].strip()
                    norm_name = self._normalize(full_name)
                    try:
                        rating = float(row['AverageRating'])
                        if rating > 0:
                            brand = norm_name.split('-')[0].strip()
                            if brand not in self.brand_ratings or rating > self.brand_ratings[brand]:
                                self.brand_ratings[brand] = rating
                    except: continue
        except: pass

    def _init_firebase(self, path):
        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(path)
                firebase_admin.initialize_app(cred)
            self.db = firestore.client()
        except Exception as e:
            print(f"Firebase Error: {e}")

    def _load_all_data(self):
        if not self.db: return
        try:
            docs = self.db.collection('products').stream()
            raw_data = [doc.to_dict() for doc in docs]
            if not raw_data: 
                self.products_df = pd.DataFrame()
                return
            self.products_df = pd.DataFrame(raw_data)
            self._assign_integer_ratings()
        except Exception as e:
            print(f"Data Load Error: {e}")

    def _assign_integer_ratings(self):
        if not self.db: return
        updated_count = 0
        for index, row in self.products_df.iterrows():
            current_rating = 0
            try: current_rating = float(row.get('averageRating', 0))
            except: pass
            if current_rating == 0:
                product_id = row.get('productId')
                brand = self._normalize(str(row.get('productName', ''))).split()[0]
                pred = self.brand_ratings.get(brand, 3.5 + random.random())
                final = int(round(pred))
                try:
                    self.db.collection('products').document(product_id).update({
                        'averageRating': final, 'productRating': final, 'is_ai_predicted': True
                    })
                    self.products_df.at[index, 'averageRating'] = final
                    updated_count += 1
                except: pass

    def update_product_rating(self, product_id, new_rating):
        if not self.db: return False
        try:
            ref = self.db.collection('products').document(product_id)
            doc = ref.get()
            if not doc.exists: return False
            data = doc.to_dict()
            reviews = data.get('reviews', [])
            reviews.append({'rating': int(new_rating)})
            all_r = [r['rating'] for r in reviews if 'rating' in r]
            avg = int(round(sum(all_r) / len(all_r)))
            ref.update({'averageRating': avg, 'productRating': avg, 'reviews': reviews, 'is_ai_predicted': False})
            self._load_all_data() # Refresh memory
            return True
        except: return False

    def recommend_by_query(self, query_text, city=None, min_rating=None, price_category=None, top_n=10):
        # ALWAYS FETCH LATEST DATA FROM FIRESTORE (Real-time sync)
        self._load_all_data()
        
        if self.products_df.empty: 
            return {'success': False, 'message': 'No food items available.', 'recommendations': []}
            
        parsed = self.parser.parse(query_text)
        dish = parsed['dish']
        intent = (price_category or parsed['price_category'] or '').lower()
        
        temp = self.products_df.copy()
        temp['averageRating'] = temp['averageRating'].fillna(3).astype(int)
        temp['productPrice'] = pd.to_numeric(temp['productPrice'], errors='coerce').fillna(0)
        
        # STRICT DISH FILTERING
        if dish:
            dish_l = dish.lower().strip()
            mask = temp['productName'].str.lower().str.contains(dish_l, na=False) | \
                   temp['catagory'].str.lower().str.contains(dish_l, na=False)
            
            if not any(mask):
                return {
                    'success': False, 
                    'message': f"Sorry, '{dish.capitalize()}' is not available right now. Please try another dish.", 
                    'recommendations': []
                }
            temp = temp[mask]
        else:
            # Fallback: if no recognized dish, check for any unmapped keywords
            keywords = parsed.get('keywords', [])
            if keywords:
                kw_masks = []
                for kw in keywords:
                    if kw.lower() in ['expensive', 'high', 'cheap', 'low', 'premium', 'budget']: continue
                    kw_mask = temp['productName'].str.lower().str.contains(kw.lower(), na=False) | \
                              temp['catagory'].str.lower().str.contains(kw.lower(), na=False)
                    kw_masks.append(kw_mask)
                
                if kw_masks:
                    combined_mask = kw_masks[0]
                    for m in kw_masks[1:]:
                        combined_mask = combined_mask | m
                    
                    if not any(combined_mask):
                        return {
                            'success': False,
                            'message': 'Sorry, this item is not available right now.',
                            'recommendations': []
                        }
                    temp = temp[combined_mask]


        # Sorting
        if 'low' in intent or 'cheap' in query_text.lower():
            temp = temp.sort_values(by=['productPrice', 'averageRating'], ascending=[True, False])
        elif 'high' in intent or 'expensive' in query_text.lower():
            temp = temp.sort_values(by=['productPrice', 'averageRating'], ascending=[False, False])
        else:
            temp = temp.sort_values(by=['averageRating', 'productPrice'], ascending=[False, True])

        recs = []
        for _, row in temp.head(top_n).iterrows():
            rating = int(row.get('averageRating', 3))
            cat = str(row.get('catagory', 'Food'))
            reason = f"Budget-friendly {cat}." if 'low' in intent else f"Top-rated {cat}."
            if 'high' in intent: reason = f"Premium {cat} choice."
            
            recs.append({
                'foodName': str(row.get('productName', 'Unknown')),
                'price': f"Rs. {int(row.get('productPrice', 0))}",
                'rating': rating,
                'reason': reason,
                'productId': str(row.get('productId', '')),
                'productImage': str(row.get('productImage', '')),
                'productOwner': str(row.get('productOwner', '')),
                'catagory': cat,
                'is_ai_predicted': bool(row.get('is_ai_predicted', False))
            })
            
        import sys
        sys.stdout.flush()
        return {'success': True, 'recommendations': recs}

    def recommend_popular(self, top_n=15):
        self._load_all_data() # Refresh
        if self.products_df.empty: return []
        res = self.products_df.sort_values(by=['averageRating', 'productPrice'], ascending=[False, True])
        return res.head(top_n).to_dict('records')

    def sync_from_live_data(self, product_list):
        self._load_all_data() # Refresh from Firestore directly
