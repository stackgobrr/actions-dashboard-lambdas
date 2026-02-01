# Actions Dashboard Lambdas

AWS Lambda functions that implement GitHub OAuth authentication for the [Actions Dashboard](https://github.com/stackgobrr/actions-dashboard).

## Overview

This repository contains two Lambda functions that handle the GitHub OAuth flow:

| Lambda | Purpose |
|--------|---------|
| `oauth-start` | Initiates OAuth by redirecting users to GitHub's authorisation page |
| `oauth-callback` | Handles the callback from GitHub, exchanges the auth code for an access token |

## OAuth Flow

```
┌──────────┐      ┌──────────────┐      ┌────────┐      ┌────────────────┐
│  User    │──1──▶│ oauth-start  │──2──▶│ GitHub │──3──▶│ oauth-callback │
│ Browser  │◀─────│    Lambda    │      │  Auth  │      │     Lambda     │
└──────────┘   6  └──────────────┘      └────────┘      └───────┬────────┘
                                                                │ 4,5
                                                                ▼
                                                        ┌──────────────┐
                                                        │ GitHub Token │
                                                        │   Endpoint   │
                                                        └──────────────┘
```

1. User clicks "Login with GitHub" → request hits `oauth-start`
2. Lambda generates CSRF state token, sets it in a cookie, redirects to GitHub
3. User authorises the app → GitHub redirects to `oauth-callback` with auth code
4. Lambda validates state cookie, exchanges code for access token with GitHub
5. GitHub returns access token
6. Lambda redirects user to frontend with token in URL hash (`/#token=...`)

## Setup

### 1. Create a GitHub OAuth App

1. Go to GitHub → **Settings** → **Developer settings** → **OAuth Apps**
2. Click **New OAuth App**
3. Configure:
   - **Application name**: Actions Dashboard
   - **Homepage URL**: Your dashboard URL
   - **Authorisation callback URL**: Your `oauth-callback` Lambda URL
4. Save the **Client ID** and **Client Secret**

### 2. Store Secrets in AWS Secrets Manager

Create two secrets (dev):

```bash
aws secretsmanager create-secret \
  --name dev-actions-dashboard/oauth-client-id \
  --secret-string "<client-id>"

aws secretsmanager create-secret \
  --name dev-actions-dashboard/oauth-client-secret \
  --secret-string "<client-secret>"
```

Create two secrets (prod):

```bash
aws secretsmanager create-secret \
  --name actions-dashboard/oauth-client-id \
  --secret-string "<client-id>"

aws secretsmanager create-secret \
  --name actions-dashboard/oauth-client-secret \
  --secret-string "<client-secret>"
```

## Deployment

Deployment is handled automatically via GitHub Actions:

- **Push to `main`** → deploys to Dev environment
- **Push a tag `v*`** → deploys to Prod environment

The workflow:
1. Provisions S3 bucket for artifacts (via Terraform)
2. Installs dependencies and packages each Lambda as a zip
3. Uploads zips to S3 with commit SHA in filename
4. Generates a deployment manifest

## Permissions

The OAuth app requests these GitHub scopes:
- `read:user` - Read user profile information
- `repo` - Access to repositories

## License

MIT
