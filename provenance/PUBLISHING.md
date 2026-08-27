# Publishing checklist

The integration target is
`https://github.com/thuer-awesome/wulpus.git`. It is separate from the official
upstream repositories `pulp-bio/wulpus` and `pulp-bio/wulpus-pro`; never push
this archive to either upstream product repository. The target initially
contained a one-line README, which is retained as the parent of the local
integration merge commit.

Publish from this directory:

```powershell
git lfs push --all origin main
git push -u origin main
```

If the target does not provide the optional LFS locking endpoint, disable only
the lock probe for this remote before retrying:

```powershell
git config lfs.https://github.com/thuer-awesome/wulpus.git/info/lfs.locksverify false
```

Before pushing, confirm `git remote -v`, enable Git LFS on the destination, and
run all three local checks:

```powershell
python tools/scripts/generate_manifest.py --check
python tools/scripts/validate_repository.py --check-manifest
python tools/scripts/check_markdown_links.py
```

After pushing, verify the commit and LFS payload from a fresh checkout:

```powershell
git ls-remote origin refs/heads/main
git clone https://github.com/thuer-awesome/wulpus.git <fresh-checkout>
git -C <fresh-checkout> lfs pull
python <fresh-checkout>/tools/scripts/generate_manifest.py --check
python <fresh-checkout>/tools/scripts/validate_repository.py --check-manifest
```

The upstream source commits and the local commit IDs are recorded in
`SOURCE_REPOSITORIES.md` and the root changelog. Do not report the archive as
published until `git ls-remote` returns the expected local `main` commit.
