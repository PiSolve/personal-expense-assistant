# Deployment Setup

This project uses GitHub Actions to automatically build Flutter web and deploy to Vercel.

## Required GitHub Secrets

Set up these secrets in your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

### Application Secrets
- `OPENAI_API_KEY` - Your OpenAI API key for AI-powered expense parsing
- `GOOGLE_WEB_CLIENT_ID` - Google OAuth web client ID for Google Sheets integration
- `OPENAI_MODEL` - (Optional) OpenAI model to use (defaults to `gpt-3.5-turbo`)

### Vercel Deployment Secrets
- `VERCEL_TOKEN` - Your Vercel personal access token
- `VERCEL_ORG_ID` - Your Vercel organization/team ID  
- `VERCEL_PROJECT_ID` - Your Vercel project ID

## Getting Vercel Secrets

### 1. Vercel Token
1. Go to [Vercel Account Settings](https://vercel.com/account/tokens)
2. Create a new token
3. Copy the token value

### 2. Organization ID  
1. Go to your [Vercel Dashboard](https://vercel.com/dashboard)
2. Go to Settings → General
3. Copy the "Team ID" value

### 3. Project ID
1. Go to your Vercel project dashboard
2. Go to Settings → General  
3. Copy the "Project ID" value

## Deployment Process

1. **Push to main branch** → GitHub Actions automatically:
   - Sets up Flutter environment
   - Creates `.env` file with secrets
   - Builds Flutter web (`flutter build web --release`)
   - Deploys to Vercel using pre-built files

2. **Pull requests** → Builds only (no deployment) to verify the app compiles

## Local Development

```bash
# Install dependencies
flutter pub get

# Create .env file (copy from env_template.txt)
cp env_template.txt .env
# Edit .env with your actual API keys

# Run locally
flutter run -d chrome
```

## Troubleshooting

- **Build fails**: Check that all GitHub Secrets are properly set
- **API errors**: Verify your OpenAI and Google API keys are valid
- **Deployment fails**: Check Vercel token permissions and project IDs

## Architecture

- **Source**: Flutter app in main branch
- **Build**: GitHub Actions (Ubuntu runner with Flutter 3.19.6)
- **Deploy**: Vercel (static files from `build/web`)
- **Runtime**: No server-side processing (static SPA) 