// Content repository — Clean Architecture data layer pattern
// Provides O(1) lookups by ID for performance in the learning app.
// Auth/DB remain OFF. Offline content only. No secrets or network.

import type { VocabExtraItem } from './types';
import { items as verbItems } from './verbs';
import { items as nounItems } from './nouns';

const allItems: VocabExtraItem[] = [...verbItems, ...nounItems];

class VocabRepository {
  private readonly byId: Map<string, VocabExtraItem>;
  private readonly byType: Map<string, VocabExtraItem[]>;

  constructor(items: VocabExtraItem[]) {
    this.byId = new Map();
    this.byType = new Map();
    for (const item of items) {
      if (this.byId.has(item.id)) {
        throw new Error(`Duplicate vocab ID detected: ${item.id}`);
      }
      this.byId.set(item.id, item);
      const list = this.byType.get(item.type) ?? [];
      list.push(item);
      this.byType.set(item.type, list);
    }
  }

  getById(id: string): VocabExtraItem | undefined {
    return this.byId.get(id);
  }

  getAll(): VocabExtraItem[] {
    return Array.from(this.byId.values());
  }

  getByType(type: 'verb' | 'noun'): VocabExtraItem[] {
    return this.byType.get(type) ?? [];
  }

  getByLevel(level: 'A1' | 'A2'): VocabExtraItem[] {
    return this.getAll().filter(item => item.level === level);
  }

  size(): number {
    return this.byId.size;
  }
}

export const vocabRepository = new VocabRepository(allItems);
export const vocabExtra = allItems; // re-export for compatibility

export { VocabRepository };
