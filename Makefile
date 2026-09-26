# Makefile
.PHONY: help git-push create-structure create-env help-dependencies install-dependencies clean lint format install-pre-commit pre-commit run build-docker run-docker install-project test-project publish-project

# include .env
# export $(shell sed 's/=.*//' .env)

MAKEFLAGS += --silent

GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m


PROJECT_DIR := $(PWD)
PROJECT_NAME := $(shell basename $(PROJECT_DIR))
SRC_DIR := src

VENV_PATH := $(PROJECT_DIR)/.venv

IMAGE_NAME := $(PROJECT_NAME)-image
CONTAINER_NAME := $(PROJECT_NAME)-container

# ====================================================

help:  ## Show the list of available commands
	echo "All available commands:"
	echo "Virtual environment: $(VENV_PATH)"
	grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  🔹 %-35s %s\n", $$1, $$2}'

git-push:  # Push changes to Git repository
	git reset
	git add .
	git commit -m "[UPDATE] $$(date '+%Y-%m-%d %H:%M:%S')"
	git push

create-structure:  ## Create the project structure
	mkdir -p cache/ input/ logs/ output/ tests/
	echo "$(GREEN)[SUCCESS]$(NC) Project structure created successfully"


# ====================================================
#  Virtual Environment
# ====================================================

create-env: create-structure ## Create uv virtual environment (.venv in repo)
	uv venv $(VENV_PATH)
	echo "$(GREEN)[SUCCESS]$(NC) uv virtual environment created successfully"
	printf '%s\n' 'source .venv/bin/activate' > .envrc
	direnv allow
	echo "$(BLUE)[INFO]$(NC) Run the following command to install dependencies:"
	echo " make install-dependencies"

help-dependencies:  ## Show the list of available commands for dependencies
	echo "$(BLUE)[INFO]$(NC) Add dependencies:"
	echo " uv add <library-name>"
	echo " uv add --dev <library-name>"
	echo "$(BLUE)[INFO]$(NC) Remove dependencies:"
	echo " uv remove <library-name>"
	echo " uv remove --dev <library-name>"

install-dependencies:  ## Install dependencies with latest versions
	uv lock --upgrade
	uv sync
	echo "$(GREEN)[SUCCESS]$(NC) Dependencies installed successfully"


# ====================================================
#  Cleaning & Formatting
# ====================================================

clean:  ## Remove temporary files
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name '*egg-info' -exec rm -rf {} +
	echo "$(GREEN)[SUCCESS]$(NC) __pycache__/ and .egg-info/ cleared"

lint:  ## Check code quality with Ruff (without fixing)
	echo "$(BLUE)[INFO]$(NC) Checking code with Ruff..."
	uv run ruff check $(SRC_DIR)
	echo "$(GREEN)[SUCCESS]$(NC) Code checked with Ruff"

format:  ## Format Python code with Ruff (imports + formatting)
	echo "$(BLUE)[INFO]$(NC) Formatting code with Ruff..."
	uv run ruff check $(SRC_DIR) --fix
	uv run ruff format $(SRC_DIR)
	echo "$(GREEN)[SUCCESS]$(NC) Code formatted with Ruff"


# ====================================================
#  Pre-commit
# ====================================================

install-pre-commit: ## Install pre-commit, only if the project is a Git repository
	if [ -d ".git" ]; then \
		echo "$(BLUE)[INFO]$(NC) Installing pre-commit..."; \
		uv add --dev pre-commit && uv run pre-commit install; \
		echo "$(GREEN)[SUCCESS]$(NC) Pre-commit installed"; \
	else \
		echo "$(BLUE)[INFO]$(NC) Not a Git repository, skipping pre-commit installation"; \
	fi

pre-commit: ## Run pre-commit hooks on all files
	echo "$(BLUE)[INFO]$(NC) Running pre-commit hooks..."
	uv run pre-commit run --all-files
	echo "$(GREEN)[SUCCESS]$(NC) Pre-commit hooks run successfully"


# ====================================================
#  Run
# ====================================================

run:  ## Run the project
	echo "$(BLUE)[INFO]$(NC) Running the project..."
	uv run python main.py


# ====================================================
#  Docker
# ====================================================

build-docker: install-dependencies  ## Build the Docker image
	echo "$(BLUE)[INFO]$(NC) Building Docker image \"$(IMAGE_NAME)\"..."
	docker build -t $(IMAGE_NAME) .
	echo "$(GREEN)[SUCCESS]$(NC) Docker image \"$(IMAGE_NAME)\" built successfully"

run-docker: build-docker  ## Run the Docker image
	echo "$(BLUE)[INFO]$(NC) Running Docker container \"$(CONTAINER_NAME)\" from image \"$(IMAGE_NAME)\"..."
	docker run --rm --name $(CONTAINER_NAME) $(IMAGE_NAME)
	echo "$(GREEN)[SUCCESS]$(NC) Docker container \"$(CONTAINER_NAME)\" from image \"$(IMAGE_NAME)\" has been run successfully"


# ====================================================
#  Project
# ====================================================

install-project:  ## Install the project
	uv pip install -e .
	echo "$(GREEN)[SUCCESS]$(NC) Project installed successfully"

test-project: install-project  ## Test the project
	uv run pytest
	echo "$(GREEN)[SUCCESS]$(NC) Project tested successfully"

publish-project: install-project  ## Publish the project
	uv pip install --upgrade build
	uv build
	uv publish
