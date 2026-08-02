# NOTICE

This repository packages and redistributes upstream software published by
[rtk-ai](https://github.com/rtk-ai). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `rtk` | `ghcr.io/ocx-contrib/rtk-ai/rtk` | `Apache-2.0` |

---

## `rtk`

Upstream: <https://github.com/rtk-ai/rtk>
Published to `ghcr.io/ocx-contrib/rtk-ai/rtk`.

| Component | SPDX | Holder |
|---|---|---|
| RTK (`rtk`) | **Apache-2.0** | Copyright rtk-ai |

Permissive; redistribution of the compiled binary is granted provided the
license and notices are retained, per
<https://github.com/rtk-ai/rtk/blob/develop/LICENSE>. Upstream ships bare
executables in its release archives with no bundled `LICENSE` file, so the
terms are those of the upstream repository. The published binaries statically
link third-party Rust crates under permissive licenses, enumerated in
upstream's `Cargo.lock`.

The RTK name and logo are used for catalog identification under nominative fair
use; the mark remains the property of rtk-ai.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
