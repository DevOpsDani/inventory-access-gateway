# Inventory Access Gateway
Token-based gateway that enables secure, authenticated access to the Inventory Service.

## 1. High-Level System Design

```mermaid
graph TB
    subgraph "External Clients"
        Client1[Client Application]
    end
    
    subgraph "Authentication Layer"
        Cognito[AWS Cognito User Pool]
    end
    
    subgraph "Backend API"
        Backend[Token Validation and Proxy]
    end
    
    subgraph "API Layer"
        AppSync[AWS AppSync GraphQL API]
        Resolvers[GraphQL Resolvers]
    end
    
    subgraph "Data Layer"
        DynamoDB[(DynamoDB Inventory Table)]
    end
    
    subgraph "Security & Monitoring"
        IAM[IAM Roles & Policies]
        CloudWatch[CloudWatch Logs/Metrics]
    end
    
    %% Flow
    Client1 -->|Sign In / JWT| Cognito
    Cognito -->|JWT Token| Backend
    Backend -->|Authorized GraphQL Query| AppSync
    AppSync --> Resolvers
    Resolvers --> DynamoDB
    
    IAM --> AppSync
    IAM --> DynamoDB
    AppSync --> CloudWatch
    Backend --> CloudWatch

```

### Key Components & Responsibilities

| Component | Responsibility |
|-----------|----------------|
| **AWS Cognito User Pool** | User authentication, JWT token issuance, user management |
| **AWS Cognito User Groups** | Role-based access through Cognito User Groups |
| **AWS AppSync** | GraphQL API endpoint, request routing, authentication validation |
| **GraphQL Resolvers** | Business logic execution, data transformation, DynamoDB integration |
| **Amazon DynamoDB** | Inventory data storage with high availability and auto-scaling |
| **IAM Roles** | Fine-grained access control and least-privilege enforcement |

### Sequence of Operations

```mermaid
sequenceDiagram
    participant Client
    participant Cognito
    participant Backend
    participant AppSync
    participant DynamoDB

    Note over Client,DynamoDB: Authentication
    Client->>Cognito: Login (username/password)
    Cognito->>Client: JWT Token

    Note over Client,DynamoDB: API Request
    Client->>Backend: GraphQL Query + JWT
    Backend->>Cognito: Validate JWT
    Cognito->>Backend: Token Valid + User Claims

    Backend->>Backend: Check user group
    alt User not in any group
        Backend-->>Client: 403 Forbidden
    else User in group
        Backend->>AppSync: Forward GraphQL Query
        AppSync->>AppSync: Schema-level @aws_auth validation
        AppSync->>DynamoDB: Execute query if authorized
        DynamoDB->>AppSync: Query results
        AppSync->>Backend: Return results
        Backend->>Client: Return data
    end

```

## 2. Security Considerations

### Authentication Mechanism
- **JWT Tokens**: Industry-standard tokens with configurable expiration
- **Multi-Factor Authentication**: Optional for enhanced security

### Authorization & RBAC
- **User Groups**: Role-based access through Cognito User Groups
- **AppSync Schema**: Fine-grained authorization using @aws_auth to ensure users can only query data allowed for their assigned group.

### Token Lifecycle Management
- **Expiration**: Configurable token TTL (default: 1 hour access, 30 days refresh)
- **Rotation**: Automatic refresh token rotation on usage
- **Revocation**: Immediate token invalidation through Cognito APIs

## 3. Infrastructure & DevOps Considerations

### Deployment Strategy
- **Serverless Architecture**: AWS managed services (Cognito, AppSync, DynamoDB) for zero server management
- **Application Deployment**: Application Deployment using Helm charts and ArgoCD to EKS
- **Infrastructure as Code**: Terraform modules for reproducible deployments
- **Multi-Environment**: Dev/Staging/Production environment separation

**Infrastructure Deployment flow**:
```mermaid
flowchart LR
    B[Pull Request opened]
    B --> C[Run terraform fmt 
    validate, lint]
    C --> D[Generate plan in PR
    Maybe already deploy
    to lower envs]
    D --> E[Team reviews plan]
    E --> F[Merge to main
    or prod branch]
    F --> G[terraform apply lower envs
    manual\auto promotion 
    for higher envs]
```
**Application Deployment Flow**:
```mermaid
flowchart LR
    subgraph "Code & CI"
        A[Code Commit] --> B[Build Docker Image]
        B --> C[Security & Compliance Scans]
        C --> D[Push Approved Image]
    end

    subgraph "GitOps Lower Envs"
        D --> E[Update Dev/Test GitOps Repo With latest tag]
        E --> F[ArgoCD Sync & Deploy to Lower Envs]
        F --> G[Integration & QA Tests]
    end

    subgraph "Staging"
        G --> H[Promote Image Tag to Staging GitOps]
        H --> I[ArgoCD Sync & Deploy to Staging]
    end

    subgraph "Production"
        I --> J[Manual or Auto Approval]
        J --> K[Update Prod GitOps Repo]
        K --> L[ArgoCD Sync & Deploy to Prod]
    end
```


### Observability Stack
- **Metrics**: CloudWatch custom metrics for API performance and usage
- **Logging**: Collect and centralize application\appsync\cognito logs for monitoring and troubleshooting. 
- **Alerting**: Automated alerts for error rates, latency, and security events

### Secrets Management
- **AWS Secrets Manager**: Securely store and manage database credentials, API keys, and other sensitive configuration data.

## 4. Scalability & Extensibility

### Multi-Tenant Support
- **Tenant Isolation**: After a user signs up, a tenant identifier is sent to a Post Confirmation Lambda, which automatically assigns the user to the appropriate Cognito group. This ensures each user is linked to the correct tenant, enabling the application to enforce tenant-specific access and maintain strict data isolation across organizations.

### Horizontal Scalability
- **Auto-Scaling**: Usage of managed services for out of the box scaling
- **Global Distribution**: Multi-region deployment capability
- **Caching**: AppSync query result caching for improved performance
- **HPA**: HPA for horizontal pod autoscaling 

## 5. Technology Choices

### Core Technologies
| Technology | Justification |
|------------|---------------|
| **AWS AppSync** | Managed GraphQL service that simplifies data access and integrates seamlessly with Cognito and DynamoDB for secure, scalable APIs. |
| **AWS Cognito** | Provides managed authentication and authorization with JWT support, user groups, and federated identity integration. |
| **Amazon DynamoDB** | Serverless NoSQL database offering high availability, auto-scaling, and predictable performance for multi-tenant data storage. |
| **Terraform** | Infrastructure as Code (IaC) tool ensuring consistent, version-controlled AWS resource provisioning. |
| **Python Flask application** | Lightweight backend responsible for authenticating users, validating JWTs, and securely forwarding GraphQL queries to AppSync. |
| **EKS** | Running the backend application, assuming this is the orchestarting system at Stream |
| **Helm** | Managing kubernetes components lifecycle |

### Testing the implemenation
This link contains a working prototype and skeleton implementation - [inventory-access-gateway](https://github.com/DevOpsDani/inventory-access-gateway)

Under test-api folder we can run the ```query.sh``` script. 

This simulates querying the service backend. 
The script requires two parameters:
we will pass 2 parameters
1) The domain name of the backend service
2) Valid JWT from cognito login

```
➜  ./query.sh <backend-domain.com> <valild JWT>
➜ {"appsync_response":{"data":{"getItems":[{"data":"{\"some\":\"value\"}","id":"1","tenant":"example-client-tenant-dev"}]}}}
```

If we will pass random JWT or the user that associated with the JWT is not part of an alllowed group to query appsync we will get
```
➜ {"error":"Invalid or expired token"}
```
