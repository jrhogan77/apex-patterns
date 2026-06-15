# Apex Patterns
### Production-Grade Salesforce Backend Architecture

This repository demonstrates enterprise-level Apex development patterns applied across real-world Salesforce implementations. Every pattern here reflects decisions made under production constraints — scalability, governor limits, maintainability, and long-term operational integrity.

---

## Design Philosophy

- **`with sharing` always.** Security is not optional.
- **No DML in loops. No SOQL in loops.** Ever.
- **`USER_MODE` on all queries.** FLS and object permissions enforced at the data layer.
- **Service layer separation.** Controllers delegate. Services execute. Never the other way around.
- **Bulkification by default.** Every method assumes 200+ records from day one.

---

## Pattern Library

### 1. Service Layer Architecture
Separates business logic from trigger context and controller calls. One entry point per domain object. Stateless, bulkified, testable in isolation.

```
classes/
├── AccountService.cls          — Domain logic for Account operations
├── AccountServiceTest.cls      — Full coverage with @TestSetup
├── OpportunityService.cls
└── OpportunityServiceTest.cls
```

### 2. Trigger Framework
Single trigger per object. Handler class per object. Logic never lives in the trigger file itself.

```
triggers/
└── AccountTrigger.trigger      — One trigger, delegates to handler

classes/
├── TriggerHandler.cls          — Base handler (virtual)
└── AccountTriggerHandler.cls   — Extends base, implements context methods
```

### 3. Async Processing Patterns
Queueable chains, Batch Apex with stateful processing, and Scheduled jobs — all with proper error handling and logging.

### 4. Integration Callout Architecture
Named Credential-based HTTP callouts with retry logic, structured error handling, and full request/response logging. Zero hardcoded endpoints.

### 5. Invocable Apex for Flow
`@InvocableMethod` patterns that expose Apex capability to Flow Builder without coupling logic to the flow layer.

---

## Standards Applied

| Standard | Implementation |
|---|---|
| Sharing Model | `with sharing` on every class |
| SOQL Mode | `WITH USER_MODE` on all queries |
| Bulk Safety | Collections-first, no per-record DML |
| Test Coverage | `@IsTest` + `@TestSetup` + explicit assertions |
| Callout Pattern | Named Credentials only — no hardcoded URLs |
| Error Handling | Custom exception classes, structured logging |

---

## About

Built by **Jason Hogan** — Salesforce Solutions Architect & AI Engineer based in St. George, Utah.

- LinkedIn: [jason-hogan1](https://www.linkedin.com/in/jason-hogan1/)
- GitHub: [@jrhogan77](https://github.com/jrhogan77)
- Email: jrhogan.tbd@gmail.com
