## [develop-v1.0.0] - 2026-03-05

### 🚀 Features

- Initial repository with Docker dev container images
- Add cross-language validation tools to all dev containers (#15)
- *(dev-go)* Add go-test-coverage to Go dev image (#17)

### 🐛 Bug Fixes

- Scope standalone markdownlint step to README.md only (#197) (#13)
- Update trivyignore for new CVEs and pin go-test-coverage (#21)
- Pin go-test-coverage to v2.18.3 for hadolint DL3062

### 📚 Documentation

- Add MkDocs/mike documentation site (#4)
- Document GHCR package access prerequisites for publishing (#6)
- Add GHCR publishing prerequisites to MkDocs site (#8)

### 🎨 Styling

- Fix table alignment and code fence language for markdownlint (#5)

### ⚙️ Miscellaneous Tasks

- Suppress four new CVEs in trivyignore
- Use .markdownlintignore for lint exclusions (#190) (#9)
- Install standard-tooling plugin via marketplace (#12)
- Prepare release 1.0.0
- Merge main into release/1.0.0
