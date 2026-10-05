import os
import sys
import json
import urllib.request

OPENAI_KEY = os.environ.get("OPENAI_API_KEY", "")
GEMINI_KEY = os.environ.get("GEMINI_API_KEY", "")
ISSUE_TITLE = os.environ.get("ISSUE_TITLE", "")
ISSUE_BODY = os.environ.get("ISSUE_BODY", "")
TRIGGER_TYPE = os.environ.get("TRIGGER_TYPE", "issue_opened")

def call_openai(prompt, system_role):
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENAI_KEY}"
    }
    data = {
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": system_role},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.2
    }
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode('utf-8'))
            return res["choices"][0]["message"]["content"]
    except Exception as e:
        return f"OpenAI Error: {e}"

def call_gemini(prompt, system_role):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key={GEMINI_KEY}"
    headers = {"Content-Type": "application/json"}
    data = {
        "system_instruction": {"parts": [{"text": system_role}]},
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.2}
    }
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode('utf-8'))
            return res["candidates"][0]["content"]["parts"][0]["text"]
    except Exception as e:
        return f"Gemini Error: {e}"

chatgpt_role = "أنت كبير مهندسي ومصممي Flutter لتطبيق 'Deutsch بالعربي'. وظيفتك اقتراح تصاميم عصرية وكتابة أكواد معمارية نظيفة."
gemini_role = "أنت المدقق المعماري ورئيس الأمان واللسانيات لتطبيق 'Deutsch بالعربي'. وظيفتك نقد الكود المقترح، اكتشاف الأخطاء، وضمان عدم كسر التطبيق."

output_reply = ""

if TRIGGER_TYPE == "issue_opened":
    prompt = f"عنوان المهمة: {ISSUE_TITLE}\nالتفاصيل: {ISSUE_BODY}\n\nقدّم تحليلاً معمارياً واقتراحاً تفصيلياً مع الكود لزميلك المدقق Gemini."
    gpt_response = call_openai(prompt, chatgpt_role)
    
    gemini_prompt = f"هذا هو مقترح ChatGPT لتنفيذ المهمة:\n\n{gpt_response}\n\nقم بالتدقيق المعماري، نقد الأمان والـ UI، وبيان نقاط القوة والضعف والاعتماد."
    gem_response = call_gemini(gemini_prompt, gemini_role)
    
    output_reply = f"### 🤖 اقتراح المهندس (ChatGPT / GPT-4o):\n\n{gpt_response}\n\n---\n\n### 🛡️ مراجعة المدقق المعماري (Gemini Pro):\n\n{gem_response}"

with open("agent_reply.md", "w", encoding="utf-8") as f:
    f.write(output_reply)
print("Agent dialogue generated successfully")
