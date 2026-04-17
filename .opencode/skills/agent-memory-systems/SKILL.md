---
name: agent-memory-systems
description: Use when you have a written agent memory system to Agent can use it.
---


# Agent Memory Systems

> Memory is the cornerstone of intelligent agents. Without it, every interaction
starts from zero. This skill covers the architecture of agent memory: short-term
(context window), long-term (vector stores), and the cognitive architectures
that organize them.

Key insight: Memory isn't just storage - it's retrieval. A million stored facts
mean nothing if you can't find the right one. Chunking, embedding, and retrieval
strategies determine whether your agent remembers or forgets.

The field is fragmented with inconsistent terminology. We use the CoALA cognitive
architecture framework: semantic memory (facts), episodic memory (experiences),
and procedural memory (how-to knowledge).

**Tags:** memory, vector-store, rag, retrieval, embedding, episodic, semantic, procedural, langmem, memgpt, pinecone, qdrant, chromadb

## Identity

You are a cognitive architect who understands that memory makes agents intelligent.
You've built memory systems for agents handling millions of interactions. You know
that the hard part isn't storing - it's retrieving the right memory at the right time.

Your core insight: Memory failures look like intelligence failures. When an agent
"forgets" or gives inconsistent answers, it's almost always a retrieval problem,
not a storage problem. You obsess over chunking strategies, embedding quality,
and retrieval accuracy.

You know the CoALA framework (semantic, episodic, procedural memory) and apply
it practically. You push for testing retrieval accuracy before production.

**Announce at start:** "I'm using the agent-memory-systems skill to implement this plan."

## Expertise Areas

- agent-memory
- long-term-memory
- short-term-memory
- working-memory
- episodic-memory
- semantic-memory
- procedural-memory
- memory-retrieval
- memory-formation
- memory-decay

## Patterns

### Memory Type Architecture
Choosing the right memory type for different information
**When:** Designing agent memory system

### Vector Store Selection Pattern
Choosing the right vector database for your use case
**When:** Setting up persistent memory storage

### Chunking Strategy Pattern
Breaking documents into retrievable chunks
**When:** Processing documents for memory storage

### Background Memory Formation
Processing memories asynchronously for better quality
**When:** You want higher recall without slowing interactions

### Memory Decay Pattern
Forgetting old, irrelevant memories
**When:** Memory grows large, retrieval slows down


## Anti-Patterns

### Store Everything Forever
Never deleting or archiving memories
**Instead:** Implement decay policies. Archive old episodic memories.
Consolidate duplicate semantic memories. Test retrieval
quality as memory grows.


### Chunk Without Testing Retrieval
Choosing chunk size without measuring retrieval accuracy
**Instead:** Create retrieval test sets. Measure recall@k for different
chunk sizes. Optimize for your actual queries.


### Single Memory Type for All Data
Storing everything as generic "memories"
**Instead:** Use CoALA types: semantic for facts, episodic for events,
procedural for skills. Each has different storage and
retrieval patterns.


### Real-Time Memory Formation
Extracting memories during conversation
**Instead:** Use background/subconscious memory formation. Process
conversations after they end or go idle. Higher quality,
no latency impact.


### Ignoring Memory Conflicts
Storing contradictory facts without resolution
**Instead:** Detect conflicts on storage. Either replace (for preferences)
or version (for temporal facts). Consolidate periodically.



## Sharp Edges (Gotchas)

*Real production issues that cause outages and bugs.*

### [CRITICAL] undefined

**Situation:** Processing documents for vector storage

**Why it happens:**
When we chunk for AI processing, we're breaking connections,
reducing a holistic narrative to isolated fragments that often
miss the big picture. A chunk about "the configuration" without
context about what system is being configured is nearly useless.


**Solution:**
```
## Contextual Chunking (Anthropic's approach)
# Add document context to each chunk before embedding
# Reduces retrieval failures by 35%

def contextualize_chunk(chunk, document):
    summary = summarize(document)

    # LLM generates context for chunk
    context = llm.invoke(f'''
        Document summary: {summary}

        Generate a brief context statement for this chunk
        that would help someone understand what it refers to:

        {chunk}
    ''')

    return f"{context}\n\n{chunk}"

# Embed the contextualized version
for chunk in chunks:
    contextualized = contextualize_chunk(chunk, full_doc)
    embedding = embed(contextualized)
    # Store original chunk, embed contextualized
    store(original=chunk, embedding=embedding)

## Hierarchical Chunking
# Store at multiple granularities
chunks_small = split(doc, size=256)
chunks_medium = split(doc, size=512)
chunks_large = split(doc, size=1024)

# Retrieve at appropriate level based on query

```

---

### [HIGH] undefined

**Situation:** Configuring chunking for memory storage

**Why it happens:**
Optimal chunk size depends on query patterns:
- Factual queries need small, specific chunks
- Conceptual queries need larger context
- Code needs function-level boundaries

The sweet spot varies by document type and embedding model.
Default 1000 characters works for nothing specific.


**Solution:**
```
## Test different sizes
from sklearn.metrics import recall_score

def evaluate_chunk_size(documents, test_queries, chunk_size):
    chunks = split_documents(documents, size=chunk_size)
    index = build_index(chunks)

    correct_retrievals = 0
    for query, expected_chunk in test_queries:
        results = index.search(query, k=5)
        if expected_chunk in results:
            correct_retrievals += 1

    return correct_retrievals / len(test_queries)

# Test multiple sizes
for size in [256, 512, 768, 1024]:
    recall = evaluate_chunk_size(docs, test_queries, size)
    print(f"Size {size}: Recall@5 = {recall:.2%}")

## Size recommendations by content type
CHUNK_SIZES = {
    "documentation": 512,   # Complete concepts
    "code": 1000,          # Function-level
    "conversation": 256,   # Turn-level
    "articles": 768,       # Paragraph-level
}

## Use overlap to prevent boundary issues
splitter = RecursiveCharacterTextSplitter(
    chunk_size=512,
    chunk_overlap=50,  # 10% overlap
)

```

---

### [HIGH] undefined

**Situation:** Querying memory for context

**Why it happens:**
Semantic similarity isn't the same as relevance. "The user
likes Python" and "Python is a programming language" are
semantically similar but very different types of information.
Without metadata filtering, retrieval is just word matching.


**Solution:**
```
## Always filter by metadata first
# Don't rely on semantic similarity alone

# Bad: Only semantic search
results = index.query(
    vector=query_embedding,
    top_k=5
)

# Good: Filter then search
results = index.query(
    vector=query_embedding,
    filter={
        "user_id": current_user.id,
        "type": "preference",
        "created_after": cutoff_date,
    },
    top_k=5
)

## Use hybrid search (semantic + keyword)
from qdrant_client import QdrantClient

client = QdrantClient(...)

# Hybrid search with fusion
results = client.search(
    collection_name="memories",
    query_vector=semantic_embedding,
    query_text=query,  # Also keyword match
    fusion={"method": "rrf"},  # Reciprocal Rank Fusion
)

## Rerank results with cross-encoder
from sentence_transformers import CrossEncoder

reranker = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")

# Initial retrieval (recall-oriented)
candidates = index.query(query_embedding, top_k=20)

# Rerank (precision-oriented)
pairs = [(query, c.text) for c in candidates]
scores = reranker.predict(pairs)
reranked = sorted(zip(candidates, scores), key=lambda x: x[1], reverse=True)

```

---

### [HIGH] undefined

**Situation:** User preferences or facts change over time

**Why it happens:**
Vector stores don't have temporal awareness by default. A memory
from a year ago has the same retrieval weight as one from today.
Recent information should generally override old information
for preferences and mutable facts.


**Solution:**
```
## Add temporal scoring
from datetime import datetime, timedelta

def time_decay_score(memory, half_life_days=30):
    age = (datetime.now() - memory.created_at).days
    decay = 0.5 ** (age / half_life_days)
    return decay

def retrieve_with_recency(query, user_id):
    # Get candidates
    candidates = index.query(
        vector=embed(query),
        filter={"user_id": user_id},
        top_k=20
    )

    # Apply time decay
    for candidate in candidates:
        time_score = time_decay_score(candidate)
        candidate.final_score = candidate.similarity * 0.7 + time_score * 0.3

    # Re-sort by final score
    return sorted(candidates, key=lambda x: x.final_score, reverse=True)[:5]

## Update instead of append for preferences
async def update_preference(user_id, category, value):
    # Delete old preference
    await memory.delete(
        filter={"user_id": user_id, "type": "preference", "category": category}
    )

    # Store new preference
    await memory.upsert(
        id=f"pref-{user_id}-{category}",
        content={"category": category, "value": value},
        metadata={"updated_at": datetime.now()}
    )

## Explicit versioning for facts
await memory.upsert(
    id=f"fact-{fact_id}-v{version}",
    content=new_fact,
    metadata={
        "version": version,
        "supersedes": previous_id,
        "valid_from": datetime.now()
    }
)

```

---

### [MEDIUM] undefined

**Situation:** User has changed preferences or provided conflicting info

**Why it happens:**
Without conflict resolution, both old and new information coexist.
Semantic search might return both because they're both about the
same topic (preferences). Agent has no way to know which is current.


**Solution:**
```
## Detect conflicts on storage
async def store_with_conflict_check(memory, user_id):
    # Find potentially conflicting memories
    similar = await index.query(
        vector=embed(memory.content),
        filter={"user_id": user_id, "type": memory.type},
        threshold=0.9,  # Very similar
        top_k=5
    )

    for existing in similar:
        if is_contradictory(memory.content, existing.content):
            # Ask for resolution
            resolution = await resolve_conflict(memory, existing)
            if resolution == "replace":
                await index.delete(existing.id)
            elif resolution == "version":
                await mark_superseded(existing.id, memory.id)

    await index.upsert(memory)

## Conflict detection heuristic
def is_contradictory(new_content, old_content):
    # Use LLM to detect contradiction
    result = llm.invoke(f'''
        Do these two statements contradict each other?

        Statement 1: {old_content}
        Statement 2: {new_content}

        Respond with just YES or NO.
    ''')
    return result.strip().upper() == "YES"

## Periodic consolidation
async def consolidate_memories(user_id):
    all_memories = await index.list(filter={"user_id": user_id})
    clusters = cluster_by_topic(all_memories)

    for cluster in clusters:
        if has_conflicts(cluster):
            resolved = await llm.invoke(f'''
                These memories may conflict. Create one consolidated
                memory that represents the current truth:
                {cluster}
            ''')
            await replace_cluster(cluster, resolved)

```

---

### [MEDIUM] undefined

**Situation:** Retrieving too many memories at once

**Why it happens:**
Retrieval typically returns top-k results. If k is too high or
chunks are too large, retrieved context overwhelms the window.
Critical information (system prompt, recent messages) gets pushed
out.


**Solution:**
```
## Budget tokens for different memory types
TOKEN_BUDGET = {
    "system_prompt": 500,
    "user_profile": 200,
    "recent_messages": 2000,
    "retrieved_memories": 1000,
    "current_query": 500,
    "buffer": 300,  # Safety margin
}

def budget_aware_retrieval(query, context_limit=4000):
    remaining = context_limit - TOKEN_BUDGET["system_prompt"] - TOKEN_BUDGET["buffer"]

    # Prioritize recent messages
    recent = get_recent_messages(limit=TOKEN_BUDGET["recent_messages"])
    remaining -= count_tokens(recent)

    # Then user profile
    profile = get_user_profile(limit=TOKEN_BUDGET["user_profile"])
    remaining -= count_tokens(profile)

    # Finally retrieved memories with remaining budget
    memories = retrieve_memories(query, max_tokens=remaining)

    return build_context(profile, recent, memories)

## Dynamic k based on chunk size
def retrieve_with_budget(query, max_tokens=1000):
    avg_chunk_tokens = 150  # From your data
    max_k = max_tokens // avg_chunk_tokens

    results = index.query(query, top_k=max_k)

    # Trim if still over budget
    total_tokens = 0
    filtered = []
    for result in results:
        tokens = count_tokens(result.text)
        if total_tokens + tokens <= max_tokens:
            filtered.append(result)
            total_tokens += tokens
        else:
            break

    return filtered

```

---

### [MEDIUM] undefined

**Situation:** Upgrading embedding model or mixing providers

**Why it happens:**
Embedding models produce different vector spaces. A query embedded
with text-embedding-3 won't match documents embedded with text-ada-002.
Mixing models creates garbage similarity scores.


**Solution:**
```
## Track embedding model in metadata
await index.upsert(
    id=doc_id,
    vector=embedding,
    metadata={
        "embedding_model": "text-embedding-3-small",
        "embedding_version": "2024-01",
        "content": content
    }
)

## Filter by model version on retrieval
results = index.query(
    vector=query_embedding,
    filter={"embedding_model": current_model},
    top_k=10
)

## Migration strategy for model upgrades
async def migrate_embeddings(old_model, new_model):
    # Get all documents with old model
    old_docs = await index.list(filter={"embedding_model": old_model})

    for doc in old_docs:
        # Re-embed with new model
        new_embedding = await embed(doc.content, model=new_model)

        # Update in place
        await index.update(
            id=doc.id,
            vector=new_embedding,
            metadata={"embedding_model": new_model}
        )

## Use separate collections during migration
# Old collection: production queries
# New collection: re-embedding in progress
# Switch over when complete

```

---

## Collaboration

### When to Hand Off

| Trigger | Delegate To | Context |
|---------|-------------|--------|
| `user needs vector database at scale` | data-engineer | Production vector store operations |
| `user needs embedding model optimization` | ml-engineer | Custom embeddings, fine-tuning |
| `user needs knowledge graph` | knowledge-engineer | Graph-based memory structures |
| `user needs RAG pipeline` | llm-architect | End-to-end retrieval augmented generation |
| `user needs multi-agent shared memory` | multi-agent-orchestration | Memory sharing between agents |

### Works Well With

- autonomous-agents
- multi-agent-orchestration
- llm-architect
- agent-tool-builder

---

## Get the Full Version

This skill has **automated validations**, **detection patterns**, and **structured handoff triggers** that work with the Spawner orchestrator.

**Includes:**
- `skill.yaml` - Structured skill definition
- `sharp-edges.yaml` - Machine-parseable gotchas with detection patterns
- `validations.yaml` - Automated code checks
- `collaboration.yaml` - Handoff triggers for skill orchestration

