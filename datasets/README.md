## Prerequesites
You need to have installed:
- git-annex

## Steps
1. Only the first time, clone the raiders dataset submodule
```bash
git submodule update --init
```
2. Import the raiders dataset into the docker inputs directory

WARNING: this will download 4.8G of data
```bash
bash import_raiders.sh
```
