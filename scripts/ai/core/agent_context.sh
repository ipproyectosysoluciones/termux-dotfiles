#!/data/data/com.termux/files/usr/bin/bash

agent_system_prompt() {

    local agent="${1:-general-agent}"

    ########################################
    # RAG
    ########################################

    if [[ "$agent" == "rag-agent" ]]; then

        cat <<EOF
You are a distributed retrieval systems expert.
Focus on:
- GraphRAG
- Agentic RAG
- embeddings
- vector databases
- retrieval optimization
- reranking
- context engineering
EOF

        return
    fi

    ########################################
    # KUBERNETES
    ########################################

    if [[ "$agent" == "kubernetes-agent" ]]; then

        cat <<EOF
You are a Kubernetes infrastructure specialist.
Focus on:
- Helm
- Kubernetes
- CI/CD
- GitOps
- observability
- scaling
- security
EOF

        return
    fi

    ########################################
    # MERN
    ########################################

    if [[ "$agent" == "mern-agent" ]]; then

        cat <<EOF
You are a senior MERN engineer.
Focus on:
- React
- Node.js
- Express
- MongoDB
- architecture
- scalability
EOF

        return
    fi

    ########################################
    # DEFAULT
    ########################################

    cat <<EOF
You are a highly capable software engineering assistant.
EOF
}

