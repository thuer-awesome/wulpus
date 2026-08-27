# Datasheet index

The local reverse-engineering workspace contains vendor datasheet PDFs used for
engineering checks. To avoid redistributing files whose vendor terms are not
confirmed, this repository keeps the index and SHA256 manifest only:

- [`DATASHEET_INDEX.csv`](DATASHEET_INDEX.csv) lists the component and source
  reference.
- [`datasheet_manifest_sha256.csv`](datasheet_manifest_sha256.csv) records the
  local PDF hashes.

Retrieve the current PDF from the manufacturer before approving a substitution;
check the revision, absolute maximum ratings, DC-bias curves, package drawing,
and lifecycle status. Do not use a search-result snippet as a substitute for a
datasheet.

