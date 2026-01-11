from flask import Flask, render_template, request, jsonify, session, redirect, url_for
import mysql.connector
import google.generativeai as genai
from datetime import datetime
import os

app = Flask(__name__)
app.secret_key = 'kingtp_secret_key'

# --- 1. DATABASE CONFIG ---
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '03245519040',  # <--- MAKE SURE THIS IS YOUR REAL PASSWORD
    'database': 'chatbot_personalization_engine'
}

# --- 2. GOOGLE GEMINI CONFIG ---
# PASTE YOUR API KEY HERE INSIDE THE QUOTES
GENAI_API_KEY = "AIzaSyCckOO88NEEivD2d2YCE2aXfvfefD0Sfdw"

genai.configure(api_key=GENAI_API_KEY)

# UPDATED MODEL: Using the newer, faster 'gemini-2.0-flash'
model = genai.GenerativeModel('gemini-flash-latest')

def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None

# --- 3. ROUTES ---

@app.route('/')
def home():
    if 'user_id' in session:
        return render_template('index.html', user_name=session.get('user_name', 'User'))
    return redirect('/login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    
    email = request.form.get('email')
    password = request.form.get('password')
    
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        # secure query
        cursor.execute("SELECT * FROM users WHERE user_email = %s AND user_password = SHA2(%s, 256)", (email, password))
        user = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if user:
            session['user_id'] = user['user_id']
            session['user_name'] = user['user_name']
            return redirect('/')
        else:
            return render_template('login.html', error="Invalid Email or Password")
    return render_template('login.html', error="Database Connection Failed (Check app.py password)")

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('register.html')
    
    name = request.form['username']
    email = request.form['email']
    password = request.form['password']
    role = request.form.get('role', 'standard')

    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            # 1. Check if email exists
            cursor.execute("SELECT * FROM users WHERE user_email = %s", (email,))
            if cursor.fetchone():
                return render_template('register.html', error="That email is already registered!")

            # 2. MANUAL ID CALCULATION (Fix for "No Auto_Increment")
            cursor.execute("SELECT MAX(user_id) as max_id FROM users")
            result = cursor.fetchone()
            
            # If database is empty, start at 1. Otherwise, add 1 to the highest ID.
            if result and result['max_id'] is not None:
                new_id = result['max_id'] + 1
            else:
                new_id = 1

            # 3. Insert user using the Manual ID
            cursor.execute("""
                INSERT INTO users (user_id, user_name, user_email, user_password, user_role, join_date) 
                VALUES (%s, %s, %s, SHA2(%s, 256), %s, NOW())
            """, (new_id, name, email, password, role))
            
            conn.commit()
            return redirect('/login')
            
        except Exception as e:
            print(f"Register Error: {e}")
            return render_template('register.html', error=f"Error: {e}")
        finally:
            cursor.close()
            conn.close()
    return "Database Error"

@app.route('/reset', methods=['GET', 'POST'])
def reset():
    if request.method == 'GET':
        return render_template('reset.html')
    
    email = request.form['email']
    new_pass = request.form['new_password']

    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        cursor.execute("UPDATE users SET user_password = SHA2(%s, 256) WHERE user_email = %s", (new_pass, email))
        conn.commit()
        cursor.close()
        conn.close()
        return render_template('reset.html', message="Password updated! Login now.")
    return "Database Error"

# --- 4. CHAT API ---
@app.route('/api/chat', methods=['POST'])
def chat_api():
    data = request.json
    user_message = data.get('message', '')
    
    if not user_message:
        return jsonify({"reply": "I didn't hear anything."})

    try:
        # Start a chat session with instruction
        chat = model.start_chat(history=[
            {"role": "user", "parts": "You are Kingtp AI, a helpful assistant. Keep answers short."},
            {"role": "model", "parts": "Understood. I am Kingtp AI."}
        ])
        
        response = chat.send_message(user_message)
        bot_reply = response.text
    except Exception as e:
        # Print error to terminal so you can see it
        print(f"Gemini Error: {e}")
        bot_reply = "I am having trouble connecting to Google. Check the terminal for the error."

    return jsonify({"reply": bot_reply})
# --- 5. HISTORY API (NEW) ---
@app.route('/api/history', methods=['GET'])
def get_history():
    # Only allow logged-in users to see history
    if 'user_id' not in session:
        return jsonify([])
    
    user_id = session['user_id'] # Get the ID of the person currently logged in

    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            # CRITICAL FIX: We added "WHERE session_id = %s" 
            # This stops User B from seeing User A's data
            query = "SELECT * FROM chat_messages WHERE session_id = %s ORDER BY message_time ASC LIMIT 50"
            cursor.execute(query, (user_id,))
            
            messages = cursor.fetchall()
            return jsonify(messages)
        except Exception as e:
            print(f"History Error: {e}")
            return jsonify([])
        finally:
            cursor.close()
            conn.close()
    return jsonify([])

if __name__ == '__main__':
    app.run(debug=True, port=5000)