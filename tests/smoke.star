# tests/smoke.star — stable across upstream releases.
# rtk is a CLI proxy that filters/summarizes command output for LLM context.
# Assert on the contract (exit code, version shape, input-derived tokens),
# never on help/version prose.

TOOL = "rtk.exe" if ocx.target_platform.os == ocx.os.Windows else "rtk"

# Tier 1 + 2: liveness + version SHAPE (not a vendor string, not the exact version).
r_version = ocx.run(TOOL, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input. `rtk json` summarizes a JSON
# document; the keys and values it echoes come from OUR input, so they are a
# stable contract independent of any upstream wording.
ocx.write_file("sample.json", "{\"name\":\"hello\",\"count\":42}")

# --keys-only strips values and prints the structure: assert the input keys.
r_keys = ocx.run(TOOL, "json", "--keys-only", "sample.json")
expect.ok(r_keys)
expect.contains(r_keys.stdout, "name")
expect.contains(r_keys.stdout, "count")

# Plain mode echoes the values: assert the input values we supplied.
r_values = ocx.run(TOOL, "json", "sample.json")
expect.ok(r_values)
expect.contains(r_values.stdout, "42")
expect.contains(r_values.stdout, "hello")
