import os, sys, json, urllib.request

api_key = os.getenv("DEEPSEEK_API_KEY", "").strip()
if not api_key:
    print("❌ خطأ: لم يتم العثور على DEEPSEEK_API_KEY")
    sys.exit(1)

prompt = sys.argv[1] if len(sys.argv) > 1 else "قل مرحباً يا سفيان، محرك ديب سيك جاهز للمشروع."

url = "https://api.deepseek.com/chat/completions"
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

payload = {
    "model": "deepseek-chat",
    "messages": [
        {"role": "system", "content": "أنت المساعد البرمجي الفائق لمشروع Polyglot."},
        {"role": "user", "content": prompt}
    ],
    "temperature": 0.2
}

try:
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers=headers)
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read().decode('utf-8'))
        print("🤖 [DEEPSEEK RESPONSE]:\n")
        print(result["choices"][0]["message"]["content"])
except Exception as e:
    print(f"❌ خطأ أثناء الاتصال: {e}")
