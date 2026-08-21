import type { VerifiedPatternService } from '../application/verified-patterns';
import type { MarkdownJournalRepository } from '../infrastructure/markdown/journal-repository';
import type { MarkdownReviewRepository } from '../infrastructure/markdown/review-repository';

const DEFAULT_LIMIT = 8;
const MAX_EXCERPT = 800;

export type AgentMemorySearchHit = {
  id: string;
  kind: 'journal' | 'review' | 'pattern';
  date: string | null;
  excerpt: string;
};

type MemoryRecord = {
  id: string;
  kind: AgentMemorySearchHit['kind'];
  date: string | null;
  text: string;
  searchable: string;
};

function normalize(value: string): string {
  return value.toLocaleLowerCase().replace(/\s+/g, ' ').trim();
}

function termsOf(value: string): string[] {
  return normalize(value).match(/[a-z0-9]+|[\u4e00-\u9fff]+/gi) ?? [];
}

function scoreRecord(query: string, terms: string[], searchable: string): number {
  const phraseScore = searchable.includes(query) ? 10 : 0;
  const termScore = terms.filter((term) => searchable.includes(term)).length * 2;
  return phraseScore + termScore;
}

function excerptAround(text: string, query: string, terms: string[]): string {
  const normalizedText = normalize(text);
  const positions = [query, ...terms]
    .map((term) => normalizedText.indexOf(term))
    .filter((position) => position >= 0)
    .sort((a, b) => a - b);
  const position = positions[0] ?? 0;
  const start = Math.max(0, position - 180);
  const end = Math.min(text.length, start + MAX_EXCERPT);
  return `${start > 0 ? '…' : ''}${text.slice(start, end).trim()}${end < text.length ? '…' : ''}`;
}

/**
 * Read-only first-stage recall over existing authoritative data.
 * It deliberately does not create a second memory store or perform writes.
 */
export class AgentMemorySearchService {
  constructor(
    private readonly journals: Pick<MarkdownJournalRepository, 'list'>,
    private readonly reviews: Pick<MarkdownReviewRepository, 'list'>,
    private readonly verifiedPatterns: Pick<VerifiedPatternService, 'list'>,
  ) {}

  async search(input: { query: string; limit?: number }): Promise<{ hits: AgentMemorySearchHit[] }> {
    const query = normalize(input.query);
    const terms = termsOf(query);
    if (!query || !terms.length) return { hits: [] };

    const [journals, reviews, patternSnapshot] = await Promise.all([
      this.journals.list(),
      this.reviews.list(),
      this.verifiedPatterns.list(),
    ]);
    const records: MemoryRecord[] = [
      ...journals.map((item) => ({
        id: item.id,
        kind: 'journal' as const,
        date: item.date,
        text: item.body,
        searchable: normalize([item.body, item.date, ...item.projectIds].join('\n')),
      })),
      ...reviews.map((item) => ({
        id: item.id,
        kind: 'review' as const,
        date: item.periodEnd,
        text: item.body,
        searchable: normalize([item.body, item.type, item.periodStart, item.periodEnd, item.projectId ?? ''].join('\n')),
      })),
      ...patternSnapshot.patterns.map((item) => ({
        id: item.id,
        kind: 'pattern' as const,
        date: item.createdAt.slice(0, 10),
        text: `${item.statement}\n${item.evidenceSummary}`,
        searchable: normalize([item.statement, item.evidenceSummary, ...item.sourceReviewIds].join('\n')),
      })),
    ];
    const limit = Math.min(Math.max(input.limit ?? DEFAULT_LIMIT, 1), DEFAULT_LIMIT);
    const ranked = records
      .map((record) => ({ record, score: scoreRecord(query, terms, record.searchable) }))
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score || (b.record.date ?? '').localeCompare(a.record.date ?? '') || a.record.id.localeCompare(b.record.id));

    return {
      hits: ranked.slice(0, limit).map(({ record }) => ({
        id: record.id,
        kind: record.kind,
        date: record.date,
        excerpt: excerptAround(record.text, query, terms),
      })),
    };
  }
}
