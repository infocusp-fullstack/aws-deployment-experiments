# Backend Setup Guide

This is the codebase for the backend for our project written in Python FastAPI.  
Follow the steps below to set up and run it locally.

---

## 📦 Prerequisites

Ensure you have the following installed:

- [Python 3.11+](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/installation/)
- [pip-tools](https://github.com/jazzband/pip-tools) (`pip install pip-tools`)
- [virtualenv](https://virtualenv.pypa.io/en/latest/) (optional, but recommended)

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone git@github.com:infocusp-fullstack/aws-deployment-experiments.git
cd aws-deployment-experiments
```

### 2️⃣ Navigate to the Backend Folder

```bash
cd backend
```

### 3️⃣ Create a Virtual Environment

```bash
python -m venv venv
```

Activate the environment:

**MacOS and Linux**

```bash
source venv/bin/activate
```

**Windows**

```bash
venv\Scripts\activate
```

### 4️⃣ Install Dependencies

We use pip-tools for dependency management.

Install dev dependencies:

```bash
pip install --require-hashes -r dev-requirements.txt
```

This will install tools like ruff and pre-commit in your system.

Install from requirements.txt

```bash
pip install --require-hashes -r requirements.txt
```

If you update requirements.in during development, don't forget to run:

```bash
pip-compile --generate-hashes requirements.in
pip install --require-hashes -r requirements.txt
```

## Running the Backend

**Development Server**

```bash
fastapi dev
```

**Production Server**

```bash
fastapi run
```

App will be available at: http://localhost:8000

## Running Tests

We use pytest for testing.

To run all tests:

```bash
pytest
```

Run tests with coverage:

```bash
pytest --cov=app
```

## Code Quality & Formatting

We use ruff for linting and formatting. Pre-commit hooks ensure code quality before pushing.

**Run manually:**

```bash
ruff check --fix .
ruff format .
```

**Install pre-commit hooks:**

```bash
pip install pre-commit
pre-commit install
```

## 📂 Project Structure

```bash
backend/
├── app/
│   ├── main.py         # FastAPI entrypoint
│   ├── api/            # API routes
│   ├── models/         # SQLAlchemy models
│   ├── schemas/        # Pydantic schemas
│   ├── core/           # Config, utils
│   └── tests/          # Unit tests
├── requirements.in
├── requirements.txt
└── README.md
```

## ✅ Development Workflow

1. Pull latest changes from test branch.

2. Create a new branch for your feature/fix.

3. Make changes.

4. Run pre-commit run --all-files.

5. Push branch & open a PR.

## Happy coding! 🚀
