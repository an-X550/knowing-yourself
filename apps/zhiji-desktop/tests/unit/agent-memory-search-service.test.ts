import { describe, expect, it, vi } from 'vitest';
import { AgentMemorySearchService } from '../../src/main-process/agent/agent-memory-search-service';

function makeService() {
  const journals = {
    list: vi.fn(async () => [{
      schemaVersion: 1 as const,
      id: 'journal_a1',
      date: '2026-08-20',
      createdAt: '2026-08-20T00:00:00.000Z',
      updatedAt: '2026-08-20T00:00:00.000Z',
      projectIds: [],
      body: '今天验证了把行动拆成更小步骤，结果更容易完成。',
    }]),
  };
  const reviews = {
    list: vi.fn(async () => [{
      schemaVersion: 1 as const,
      id: 'review_a1',
      type: 'weekly' as const,
      periodStart: '2026-08-17',
      periodEnd: '2026-08-23',
      sourceIds: ['journal_a1'],
      projectId: null,
      provider: 'openai-compatible' as const,
      model: 'test',
      promptVersion: 'periodic-review-v1',
      createdAt: '2026-08-23T00:00:00.000Z',
      body: '本周项目方向更清晰，下一步继续验证行动拆解。',
    }]),
  };
  const verifiedPatterns = {
    list: vi.fn(async () => ({
      schemaVersion: 1 as const,
      updatedAt: '2026-08-23T00:00:00.000Z',
      patterns: [{
        schemaVersion: 1 as const,
        id: 'pattern_a1',
        statement: '拆小行动有助于持续执行。',
        evidenceSummary: '来自多个周期复盘的已确认证据。',
        sourceReviewIds: ['review_a1'],
        createdAt: '2026-08-23T00:00:00.000Z',
      }],
    })),
  };
  return { service: new AgentMemorySearchService(journals, reviews, verifiedPatterns), journals, reviews, verifiedPatterns };
}

describe('AgentMemorySearchService', () => {
  it('recalls matching journals, reviews and verified patterns from one read-only search', async () => {
    const { service, journals, reviews, verifiedPatterns } = makeService();
    const result = await service.search({ query: '行动', limit: 8 });

    expect(result.hits.map((hit) => hit.id)).toEqual(expect.arrayContaining(['review_a1', 'journal_a1', 'pattern_a1']));
    expect(result.hits[0].excerpt).toContain('行动');
    expect(journals.list).toHaveBeenCalledOnce();
    expect(reviews.list).toHaveBeenCalledOnce();
    expect(verifiedPatterns.list).toHaveBeenCalledOnce();
  });

  it('returns stable date-descending results when scores tie and respects the limit', async () => {
    const { service } = makeService();
    const result = await service.search({ query: '行动', limit: 1 });

    expect(result.hits).toHaveLength(1);
    expect(result.hits[0].date).toBe('2026-08-23');
  });

  it('returns no result for a phrase absent from the local sources', async () => {
    const { service } = makeService();

    await expect(service.search({ query: '完全不存在的内容' })).resolves.toEqual({ hits: [] });
  });
});
