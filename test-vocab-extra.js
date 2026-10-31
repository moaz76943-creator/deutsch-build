const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'src/lib/deutsch/content/vocab-extra.ts');
const content = fs.readFileSync(filePath, 'utf8');

// Extract all id fields
const idMatches = content.match(/id:\s*'([^']+)'/g) || [];
const ids = idMatches.map(m => m.match(/'([^']+)'/)[1]);

const uniqueIds = new Set(ids);
const itemCount = ids.length;

console.log(`Found ${itemCount} items, ${uniqueIds.size} unique IDs`);

if (itemCount !== uniqueIds.size) {
  console.error('FAIL: Duplicate IDs found');
  process.exit(1);
}

if (itemCount < 1) {
  console.error('FAIL: No items');
  process.exit(1);
}

// Basic checks for required fields presence
const hasPrateritum = (content.match(/präteritum:/g) || []).length > 0;
const hasDer = content.includes("article: 'der'");
const hasDie = content.includes("article: 'die'");
const hasDas = content.includes("article: 'das'");

if (!hasPrateritum) {
  console.error('FAIL: No präteritum found');
  process.exit(1);
}
if (!hasDer || !hasDie || !hasDas) {
  console.error('FAIL: Missing articles');
  process.exit(1);
}

// Check for syntax issues roughly (unclosed, etc.)
if (!content.includes('export const vocabExtra')) {
  console.error('FAIL: Missing export');
  process.exit(1);
}

console.log('PASS: All checks passed. Content integrity OK.');
process.exit(0);
