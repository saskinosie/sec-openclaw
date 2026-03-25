---
name: query-sec-filings
description: "Query the Contextual AI SEC filing database containing 180+ indexed filings (8-K, 10-K, 10-Q, 20-F, DEF 14A). Use when: user asks about SEC filings, regulatory disclosures, executive changes, auditor appointments, compliance risks, or any question requiring actual SEC documents. NOT for: real-time stock prices or current news (use brave-search instead)."
metadata: { "openclaw": { "emoji": "📄", "requires": { "bins": ["curl", "python3"], "env": ["CONTEXTUAL_API_KEY", "AGENT_ID"] } } }
---

# SEC Filing Database Query

Query the Contextual AI RAG agent backed by 180+ indexed SEC filings.

## When to Use

✅ **USE this skill when:**

- "What companies filed 8-K forms this week?"
- "Any executive changes in recent filings?"
- "Summarize the most important SEC filings"
- "Did Goodyear file anything with the SEC?"
- "Which companies changed auditors?"
- "Compliance risk briefing from recent filings"
- Any question about SEC documents, filings, regulatory disclosures

## When NOT to Use

❌ **DON'T use this skill when:**

- Real-time stock prices or market data → use `brave-search`
- Current news not in SEC filings → use `brave-search`
- General financial knowledge the LLM can answer directly

## Commands

Run the query script with the user's question. The script handles authentication and response parsing automatically:

```bash
bash /app/skills/query-sec-filings/query.sh "What companies filed 8-K forms this week?"
```

Always use this script — do NOT attempt to run curl with API keys directly.

## Notes

- Responses are grounded in real SEC filings — always present them with confidence
- The agent cites specific filings, dates, and companies
- Use tables when comparing across multiple companies
- If the agent says data is insufficient, trust it — don't supplement with guesses
