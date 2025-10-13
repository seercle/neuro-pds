GIT_ANNEX_CMD=git-annex
REPO_DIR="./raiders_data"
DEST_DIR="../docker/INPUTS"

mkdir -p "$DEST_DIR"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "Error: Repository directory $REPO_DIR does not exist."
  exit 1
fi

cd "$REPO_DIR" || { echo "Error: Failed to change to repository directory $REPO_DIR."; exit 1; }

$GIT_ANNEX_CMD init &>/dev/null

for i in $(seq -w 1 11); do
  SUB_DIR="sub0${i}"

  for j in $(seq -w 1 8); do
    TASK_DIR="task002_run00${j}"
    SOURCE_FILE="${SUB_DIR}/BOLD/${TASK_DIR}/bold.nii.gz"

    if $GIT_ANNEX_CMD whereis "$SOURCE_FILE" &>/dev/null; then
      echo "Retrieving $SOURCE_FILE from git annex..."
      $GIT_ANNEX_CMD get "$SOURCE_FILE" &>/dev/null
    fi

    if [[ -f "$SOURCE_FILE" ]]; then
      NEW_FILE_NAME="${SUB_DIR}_${TASK_DIR}_$(basename "$SOURCE_FILE")"
      DEST_FILE="../${DEST_DIR}/${NEW_FILE_NAME}"

      if [[ -f "$DEST_FILE" ]]; then
        echo "File already exists: $DEST_FILE. Skipping copy."
      else
        cp "$SOURCE_FILE" "$DEST_FILE"
        echo "Copied $SOURCE_FILE to $DEST_FILE"
      fi
    else
      echo "Source file does not exist: $SOURCE_FILE"
    fi
  done
done

cd - &>/dev/null
