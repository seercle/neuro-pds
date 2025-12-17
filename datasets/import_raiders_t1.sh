REPO_URL="http://datasets-dev.datalad.org/labs/haxby/raiders"
DEST_DIR="./RAIDERS_T1"
FILES=(
  "sub-rid000005_run-01_T1w.nii.gz"
  "sub-rid000005_run-02_T1w.nii.gz"
  "sub-rid000011_run-01_T1w.nii.gz"
  "sub-rid000011_run-02_T1w.nii.gz"
  "sub-rid000014_run-01_T1w.nii.gz"
  "sub-rid000014_run-02_T1w.nii.gz"
  "sub-rid000015_run-01_T1w.nii.gz"
  "sub-rid000015_run-02_T1w.nii.gz"
  "sub-rid000020_run-01_T1w.nii.gz"
  "sub-rid000020_run-02_T1w.nii.gz"
  "sub-rid000028_run-01_T1w.nii.gz"
  "sub-rid000028_run-02_T1w.nii.gz"
  "sub-rid000029_run-01_T1w.nii.gz"
  "sub-rid000029_run-02_T1w.nii.gz"
  "sub-rid000033_run-01_T1w.nii.gz"
  "sub-rid000033_run-02_T1w.nii.gz"
  "sub-rid000038_run-01_T1w.nii.gz"
  "sub-rid000038_run-02_T1w.nii.gz"
  "sub-rid000042_run-01_T1w.nii.gz"
  "sub-rid000042_run-02_T1w.nii.gz"
  "sub-rid000043_run-01_T1w.nii.gz"
  "sub-rid000043_run-02_T1w.nii.gz"
)

mkdir -p "$DEST_DIR"

for file in "${FILES[@]}"; do
  SUB_DIR=$(echo "$file" | cut -d '_' -f1)
  echo "Downloading ${file} from ${REPO_URL}/${SUB_DIR}/func/"
  wget "${REPO_URL}/${SUB_DIR}/anat/${file}" -O "${DEST_DIR}/${file}"
  echo "Downloaded ${file} to ${DEST_DIR}/${file}"
done
