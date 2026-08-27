# Excluded artifacts

The following local materials were deliberately kept out of the GitHub-ready
tree. They remain in the working archive for local reference, but are not part
of the reproducible release:

| Local path/pattern | Reason |
|---|---|
| `pcb_reverse_engineering/tools/kicad_portable/` | KiCad/Typst runtime, installers, caches, demos, and temporary conversions; about 6.16 GB |
| `pcb_reverse_engineering/tmp/` | Temporary renders and intermediate files |
| `pcb_reverse_engineering/commercial_fpga_reference/` | Unrelated third-party board files, memory dumps, and uncertain redistribution rights; about 302 MB |
| `tmp/` | Local scripts, screenshots, and render intermediates |
| `wulpus*/**/*.zip` full snapshot archives (`wulpus.zip`, `wulpus-pro.zip`) | Redundant full-repository archives; board-specific manufacturer ZIPs are retained beside each board |
| Vendor installer binaries and SDK packages | Licensing, size, and reproducibility; setup instructions point to the vendor download |
| User originals `BOM_12364560A_Y19.xls` and `BOM_12364560A_Y20.xls` | Private WeChat-exported files; only path/hash provenance and derived audit outputs are published |
| Third-party datasheet PDFs under `pcb_reverse_engineering/design_reference/datasheets/` | Redistribution rights are not established; names, URLs, and hashes are retained in `reference/datasheets/` |

No excluded file is required to build or order the six WULPUS boards represented
by this repository. If a future release adds any of these materials, record a
license decision and a new SHA256 manifest first.

