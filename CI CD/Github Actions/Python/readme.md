# How to make a python CI CD

CI (Continuous Integration): Automatically test code when you push changes
CD (Continuous Deployment): Automatically deploy code after tests pass

## Project structure

repo/
├── main.py
├── test_main.py
├── requirements.txt
└── .github/
    └── workflows/
        └── ci-cd.yml

## Step 1 create a requirements.txt

fastapi==0.104.1
uvicorn[standard]==0.24.0
pytest==7.4.3
httpx==0.25.2

## Step 2 create a test_main.py file

```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}

def test_health_check():
    response = client.get("/")
    assert "message" in response.json()
```

## Step 3: Create GitHub Actions Workflow
Create the directory structure and workflow file:

In our project root, create: .github/workflows/ci.yml

## Step 4: Repository Setup

Create a new repository on GitHub
Clone it locally or push our existing code
Set up branch protection (optional but recommended)

## Step 5: Workflow Triggers
Our workflow will trigger on:

Push to main branch: For deployment
Pull requests to main: For testing before merge
Manual trigger: For testing purposes

## Step 6: How It Works

Create a feature branch: git checkout -b feature/new-feature
Make changes and push: git push origin feature/new-feature
Create Pull Request: GitHub → New Pull Request
GitHub Actions runs tests: Automatically triggered
If tests pass: We can merge the PR
After merge: Deployment workflow can trigger

```
# Clone our repo
git clone https://github.com/your-username/your-repo.git
cd your-repo

# Create and switch to feature branch
git checkout -b feature/add-new-endpoint

# Make our changes, then:
git add .
git commit -m "Add new endpoint"
git push origin feature/add-new-endpoint

# Create PR on GitHub, then after merge:
git checkout main
git pull origin main
```

## Step 7 : Testing Locally
Before pushing, always test locally:

```bash

pip install -r requirements.txt

# Run tests
pytest

uvicorn main:app --reload
```

