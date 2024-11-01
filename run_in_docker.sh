#!/bin/bash

PROJECTS_DIR="/app/benchmarks/"
RESULTS_DIR="/app/results/"

SCRIPTS=("install_reqs.sh" "flame_run.sh" "mutmut_run.sh" "get_results.sh")
FILES=("mutation_scores.csv" "compare_candidates.csv")

mkdir -p "$RESULTS_DIR"

# Check if a specific project name was provided as an argument
SPECIFIC_PROJECT=$1

for PROJECT_PATH in "$PROJECTS_DIR"/*; do
  if [ -d "$PROJECT_PATH" ]; then
    PROJECT_NAME=$(basename "$PROJECT_PATH")

    # If a specific project is given, skip others
    if [ -n "$SPECIFIC_PROJECT" ] && [ "$PROJECT_NAME" != "$SPECIFIC_PROJECT" ]; then
      continue
    fi

    PROJECT_RESULTS_DIR="$RESULTS_DIR/$PROJECT_NAME"
    mkdir -p "$PROJECT_RESULTS_DIR"

    cd "$PROJECT_PATH" || continue

    python3 -m venv venv
    source venv/bin/activate

    pip install /app
    pip install git+https://github.com/python-mutation-testing/mutmut.git@mutation-type
    pip install pandas

    for SCRIPT in "${SCRIPTS[@]}"; do
      if [ -f "$SCRIPT" ]; then
        bash "$SCRIPT"
      else
        echo "Warning: $SCRIPT not found in $PROJECT_PATH"
      fi
    done

    deactivate

    for FILE in "${FILES[@]}"; do
      if [ -f "$FILE" ]; then
        cp "$FILE" "$PROJECT_RESULTS_DIR/"
      else
        echo "Warning: $FILE not found in $PROJECT_PATH"
      fi
    done

    rm -rf venv
  fi
done

pip install pandas
pip install tabulate

python /app/scripts/aggregate_results.py

echo "Script execution completed."
