# Contributing

## Local setup

```bash
python -m pip install -r <(echo -e "requests\npyyaml")
```

## Tests

```bash
python -m unittest discover -s tests -p "test_*.py"
```


## Versioning

This repo uses **automatic semver tagging** via PR labels. When a PR is merged to `main`, the [auto-tag workflow](.github/workflows/auto-tag.yml) reads the label and creates the next version tag.

| Label | Effect |
|---|---|
| `semver:patch` | Bump patch (e.g. v1.0.5 -> v1.0.6) — bug fixes, docs |
| `semver:minor` | Bump minor (e.g. v1.0.5 -> v1.1.0) — new features, backward-compatible |
| `semver:major` | Bump major (e.g. v1.0.5 -> v2.0.0) — breaking changes |
| `semver:skip` | No release on merge |
| *(no label)* | No release on merge |

Apply **exactly one** `semver:*` label to your PR before merging. Multiple semver labels will cause the workflow to fail.
