# mirror-rtk-ai

OCX mirror for [RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer). One
repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [rtk](https://github.com/rtk-ai/rtk) | [`rtk/mirror.yml`](rtk/mirror.yml) | `ghcr.io/ocx-contrib/rtk-ai/rtk` | `ocx.sh/rtk-ai/rtk` | `Apache-2.0` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/rtk`. `rtk-ai/rtk` is the grouped successor. The namespace is
> upstream's org `rtk-ai`, which owns several repositories and is therefore a
> real family rather than one person's handle.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
rtk/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`rtk` publishes five platform entries: both Linux arches, both macOS arches and
`windows/amd64` (upstream ships no aarch64 Windows asset). The two Linux keys
are **not symmetric**, because `os.features` states what an artifact requires
*of the host* and the two builds measure differently — on v0.44.2:

| Key | Asset | Measurement |
|---|---|---|
| `linux/amd64` (**bare**) | `rtk-x86_64-unknown-linux-musl.tar.gz` | static-pie — no `PT_INTERP`, no `DT_NEEDED` |
| `linux/arm64+libc.glibc` | `rtk-aarch64-unknown-linux-gnu.tar.gz` | dynamic — `/lib/ld-linux-aarch64.so.1`, needs `libgcc_s.so.1` |

amd64 requires nothing of the host, so tagging it `+libc.musl` would be a false
requirement that hid the most common install target from every glibc host. Its
`alpine:3.20` container leg is what turns "requires nothing" into evidence. The
arm64 key has **no alpine leg** — the glibc build cannot load under musl, so an
alpine leg would red on a correct artifact. Both matrices live in
`mirror-base.yml`; the measurements are recorded above the `assets:` block in
`rtk/mirror.yml`.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `rtk/mirror.yml` | hand | yes — see below |
| `rtk/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `rtk/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec rtk/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Every rtk archive holds a single flat executable at its root (`rtk`, `rtk.exe`
on Windows) with no wrapper directory, so nothing is stripped and the bundle's
only PATH entry is a bare `${installPath}` — the executable *is* the content
root. `bin_scan` only looks *below* an `${installPath}/<dir>` entry, so
`auto`/`verify` is rejected at spec load with exit 65. `mirror-base.yml`
therefore sets `bin_scan: off` and `rtk/metadata.json` hand-lists
`binaries: ["rtk"]` — the blessed shape for this asset layout.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
