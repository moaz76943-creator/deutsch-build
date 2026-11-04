import re

with open('lib/screens/phonetics_lab_screen.dart', 'r') as f:
    content = f.read()

# Fix the messy merge markers that were left
content = re.sub(r'<<<<<<< HEAD\n(.*?)\n=======\n.*?\n>>>>>>> [a-zA-Z0-9/.-]+\n', r'\1\n', content, flags=re.DOTALL)
content = re.sub(r'<<<<<<< HEAD\n(.*?)\n=======\n', r'\1\n', content, flags=re.DOTALL)
content = re.sub(r'>>>>>>> [a-zA-Z0-9/.-]+\n', '', content)
content = content.replace("return null;,", "return const SizedBox.shrink();")

with open('lib/screens/phonetics_lab_screen.dart', 'w') as f:
    f.write(content)
