# AGENTS.md

Operating rules for this repository. They override generic habits.

## Branch model

- We track **`main`**. Upstream releases and tags are not tracked; there is no
  `next`/`stable` branch and nothing merges into `main` from a release branch.
- `main` is a rebased line of our own commits on top of `miniflux/v2:main`.

## Incorporating upstream changes

Rebase, then force-push. No merge commits, ever.

```sh
git fetch upstream
git rebase upstream/main
git push --force-with-lease origin main
```

- Resolve conflicts in the rebase, keep our commits as the only non-upstream
  history, and make sure `go build ./... && go test ./...` passes afterwards.
- Force-pushing `main` is expected and allowed. Force-pushing a tag is not.

## Stable hashes: tags

- A stable reference for others is a **tag**, never a branch.
- Tags are named `r1`, `r2`, `r3`, ... (`r` = release). No semver, no upstream
  version, no date in the name — the numbering has no correlation with upstream
  versioning, it is only our own release counter.
- Tags are **never** force-pushed, moved, or deleted. Publish a new number
  instead.
- Tag the commit that has been through CI. `main` can move at any time; the tag
  is what people pin.

## SQLite backend

- `internal/database/sqlite_schema.go` is maintained by hand and must mirror
  `internal/database/migrations.go`. When upstream adds a column, the SQLite
  schema needs the same column or `internal/storage` tests fail with
  `no such column`.
- The backend is selected from `DATABASE_URL` (`sqlite:///path` or
  `postgres://...`). PostgreSQL stays the default path; do not regress it.

## Builds

- The development host is weak, so builds, tests and cross-compilation run in
  GitHub Actions (`.github/workflows/sqlite.yml`). Use `act` or a local `go
  build` only for quick checks.
- Dependencies are updated with `go get -u ./...` followed by `go mod tidy`;
  keep the version bumps and the code that adapts to them in the same commit.
- `flake.nix` builds the same binary through `buildGoModule`. If the module set
  changes such that `vendorHash` no longer matches, `nix build` in CI reports
  the expected hash — update it in the same change.
