# rtk/tests/smoke.star — stable across upstream releases.
# rtk is a CLI proxy that filters/summarizes command output for LLM context.
# Assert on the contract (exit code, version shape, computed result), never on
# help/version prose. Everything below is offline and hermetic — the only
# input is a document this script writes.
RTK = "rtk.exe" if ocx.target_platform.os == ocx.os.Windows else "rtk"

# Tier 1 + 2: liveness + version SHAPE (not a vendor string, not the version).
r_version = ocx.run(RTK, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: `rtk json` on hermetic input. The keys, values and structure it
# reports are derived from OUR document, so they are a contract independent of
# any upstream wording. A nested array is what makes the two projections below
# actually differ — on a flat two-key document rtk passes the input through
# unchanged and both modes would print the same thing.
ocx.write_file(
    "sample.json",
    "{\"name\":\"hello\",\"count\":42," +
    "\"items\":[{\"id\":1,\"label\":\"alpha\"},{\"id\":2,\"label\":\"beta\"}]}",
)

# 3a: --keys-only reduces the document to its schema — keys kept, values
# replaced by their inferred type. Both top-level keys and the nested one must
# survive that reduction.
r_keys = ocx.run(RTK, "json", "--keys-only", "sample.json")
expect.ok(r_keys)
expect.contains(r_keys.stdout, "name")
expect.contains(r_keys.stdout, "count")
expect.contains(r_keys.stdout, "label")

# 3b: plain mode keeps the values — the half --keys-only drops. The two
# together fail if either projection regresses.
r_values = ocx.run(RTK, "json", "sample.json")
expect.ok(r_values)
expect.contains(r_values.stdout, "hello")
expect.contains(r_values.stdout, "42")
expect.contains(r_values.stdout, "alpha")

# Tier 4: rtk is a self-contained proxy binary — PATH only (proven by Tier 1).
# No non-PATH env var to wire, so no Tier 4 check.
