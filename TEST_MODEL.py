import google.generativeai as genai

GENAI_API_KEY = "AIzaSyCckOO88NEEivD2d2YCE2aXfvfefD0Sfdw"
genai.configure(api_key=GENAI_API_KEY)

print("Available models:")
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)