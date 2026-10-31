// Combined offline vocab for Deutsch بالعربي
// Modular structure + repository for speed, quality, and ease of development
// Auth/DB remain OFF.

import { items as verbItems } from './verbs';
import { items as nounItems } from './nouns';
import type { VocabExtraItem } from './types';

export const vocabExtra: VocabExtraItem[] = [...verbItems, ...nounItems];

export type { VocabExtraItem, VerbConjugation } from './types';
export { vocabRepository, VocabRepository } from './repository';
