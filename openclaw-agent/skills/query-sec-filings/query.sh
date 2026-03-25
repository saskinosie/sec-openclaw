#!/bin/bash
# Query the Contextual AI SEC filing agent
# Usage: ./query.sh "your question here"

QUESTION="${1:-What SEC filings were filed this week?}"

curl -s -X POST "https://api.contextual.ai/v1/agents/${AGENT_ID}/query" \
  -H "Authorization: Bearer ${CONTEXTUAL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"messages\": [{\"role\": \"user\", \"content\": \"${QUESTION}\"}]}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['message']['content'])" 2>/dev/null \
  || echo "Error querying SEC agent"
