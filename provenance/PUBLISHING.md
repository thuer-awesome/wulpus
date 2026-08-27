# Publishing checklist

The local repository has no remote because the destination repository name and
owner were not specified, and the current environment has no authenticated
GitHub CLI/token. Do not push this archive to `pulp-bio/wulpus` or
`pulp-bio/wulpus-pro`; those are the upstream product repositories.

After the owner creates or selects a dedicated empty GitHub repository (for
example, `wulpus-hardware-embedded`), publish from this directory:

```powershell
git remote add origin https://github.com/<owner>/<repository>.git
git push -u origin main
git lfs push --all origin main
```

Before pushing, confirm `git remote -v`, enable Git LFS on the destination, and
run all three local checks:

```powershell
python tools/scripts/generate_manifest.py --check
python tools/scripts/validate_repository.py --check-manifest
python tools/scripts/check_markdown_links.py
```

The first push should be reviewed as a new integration archive. The upstream
source commits and the local commit IDs are already recorded in
`SOURCE_REPOSITORIES.md` and the root changelog.

