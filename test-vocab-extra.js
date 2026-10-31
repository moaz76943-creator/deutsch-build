const fs = require('fs');
const path = require('path');

const contentDir = path.join(__dirname, 'src/lib/deutsch/content');
const files = ['verbs.ts', 'nouns.ts', 'index.ts', 'vocab-extra.ts', 'types.ts'];

let allContent = '';
let totalIds = [];

for (const file of files) {
  const filePath = path.join(contentDir, file);
  if (fs.existsSync(filePath)) {
    const content = fs.readFileSync(filePath, 'utf8');
    allContent += content + '\n';
    if (file === 'verbs.ts' || file === 'nouns.ts') {
      const idMatches = content.match(/id:\s*'([^']+)'/g) || [];
      const ids = idMatches.map(m => m.match(/'([^']+)'/)[1]);
      totalIds.push(...ids);
    }
  }
}

const uniqueIds = new Set(totalIds);
const itemCount = totalIds.length;

console.log(`Found ${itemCount} items, ${uniqueIds.size} unique IDs`);

if (itemCount !== uniqueIds.size) {
  console.error('FAIL: Duplicate IDs found');
  process.exit(1);
}

if (itemCount < 1) {
  console.error('FAIL: No items');
  process.exit(1);
}

// Basic checks
const hasPrateritum = (allContent.match(/präteritum:/g) || []).length > 0;
const hasDer = allContent.includes("article: 'der'");
const hasDie = allContent.includes("article: 'die'");
const hasDas = allContent.includes("article: 'das'");

if (!hasPrateritum) {
  console.error('FAIL: No präteritum found');
  process.exit(1);
}
if (!hasDer || !hasDie || !hasDas) {
  console.error('FAIL: Missing articles');
  process.exit(1);
}

if (!allContent.includes('export const vocabExtra') && !allContent.includes('export { vocabExtra }')) {
  console.error('FAIL: Missing export');
  process.exit(1);
}

console.log('PASS: All checks passed. Content integrity OK. Modular structure verified.');
process.exit(0);
