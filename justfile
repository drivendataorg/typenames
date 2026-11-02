# Keep in sync with just-version in .github/workflows/*.yml
set minimum-version := '1.55.0'

python := shell("cat .python-version")

# Print this help documentation
help:
    just --list

# Sync requirements
sync:
    uv sync

# Run linting (passes through args)
lint *args:
    uv run -- ruff format --check {{args}}
    uv run -- ruff check {{args}}

# Run formatting (passes through args)
format *args:
    uv run -- ruff format {{args}}
    uv run -- ruff check --fix --extend-fixable=F {{args}}

# Audit GitHub Actions workflows with zizmor (passes through args)
zizmor *args:
    uvx --exclude-newer "7 days" zizmor .github/ {{args}}

# Run static typechecking with all typecheckers
[arg("python", long)]
typecheck python=python:
    just typecheck-mypy --python={{python}}
    just typecheck-pyrefly --python={{python}}
    just typecheck-ty --python={{python}}

# Run static typechecking with mypy (passes through args)
[arg("python", long)]
typecheck-mypy python=python *args:
    uv run --python={{python}} --isolated --no-dev --group typecheck -- \
        mypy --python-version={{python}} {{args}}

# Run static typechecking with pyrefly (passes through args)
[arg("python", long)]
typecheck-pyrefly python=python *args:
    uv run --python={{python}} --isolated --no-dev --group typecheck -- \
        pyrefly check --python-version={{python}} {{args}}

# Run static typechecking with ty (passes through args)
[arg("python", long)]
typecheck-ty python=python *args:
    uv run --python={{python}} --isolated --no-dev --group typecheck -- \
        ty check --python-version={{python}} {{args}}

# Run the tests (passes through args)
[arg("python", long)]
test python=python *args:
    uv run --python={{python}} --isolated --no-editable --no-dev --group tests --reinstall -- \
        python -I -m pytest {{args}}

# Run all tests with Python version matrix
test-all:
    for python in 3.10 3.11 3.12 3.13 3.14 3.15; do \
        just test --python=$python; \
    done

# Generate notebook that inspects types
[arg("python", long)]
inspect-types python=python:
    uv run --python={{python}} --isolated --only-group inspect-types -- \
        jupyter nbconvert inspect_types/_inspect_types.ipynb \
            --to notebook \
            --output inspect_types_{{python}}.ipynb \
            --execute \
            --allow-errors

# Generate notebook that inspects types for all Python versions
inspect-types-all:
    for python in 3.10 3.11 3.12 3.13 3.14 3.15; do \
        just inspect-types --python=$python; \
    done

# Generate docs
docs:
    uv run --directory docs mkdocs build

# Serve docs
docs-serve:
    uv run --directory docs mkdocs serve

# Pull gh-pages branch from GitHub to local
pull-gh-pages:
    git fetch origin gh-pages:gh-pages

# Push gh-pages branch from local to GitHub
push-gh-pages:
    git push origin gh-pages:gh-pages
