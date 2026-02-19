```mermaid
flowchart TB

  subgraph Static["Static website"]
    direction LR
    B["Browser"] --> R53["Route 53"]
    R53 --> CF["CloudFront"]
    CF -->|OAC| S3["S3 (private)"]
  end

  subgraph API["Visitor counter API"]
    direction LR
    B2["Browser"] --> APIGW["API Gateway: /visitors"]
    APIGW --> L["Lambda"]
    L --> DDB["DynamoDB"]
  end

  subgraph Deploy["CI/CD"]
    direction LR
    GHA["GitHub Actions"] --> OIDC["OIDC assume role (IAM)"]
    OIDC --> SYNC["S3 sync"]
    OIDC --> INV["CloudFront invalidation"]
  end
