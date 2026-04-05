# pytemplate

## Setup

1. Set the desired Python version in `.python-version`

2. Create the project environment (single venv at `~/.venvs/pytemplate-env`; uv uses `UV_PROJECT_ENVIRONMENT`) :

   ```shell
   make create-env
   ```

   Without direnv, run `export UV_PROJECT_ENVIRONMENT="$HOME/.venvs/pytemplate-env"` before `uv` commands in this repo.

3. Add the required dependencies:

   ```shell
   uv add <package_name>
   ```

4. Update the lockfile and synchronize the environment:

   ```shell
   make update-dependencies
   ```

5. Run `make install-pre-commit` to install pre-commit hooks

---

## Setup dbt

1. Install required libraries:

   ```shell
   uv add dbt-core sqlfluff sqlfluff-templater-dbt dbt-athena-community
   ```

   Then add to `.vscode/settings.json`:

   ```
   "sqlfluff.executablePath": "${userHome}/.venvs/pytemplate-env/bin/sqlfluff"
   "sqlfluff.dialect": "athena"
   ```

2. Create a dbt project:

   ```shell
   mkdir -p dbt
   cd dbt
   dbt init <my_project_name>
   ```

3. Run the following command:

   ```shell
   cat <<EOF > .sqlfluff
   [sqlfluff]
   dialect = athena
   templater = dbt

   [sqlfluff:templater:dbt]
   project_dir = .
   profiles_dir = ~/.dbt

   [sqlfluff:indentation]
   tab_width = 4
   EOF
   ```
