# Well-Cost-Management - Claude Development Guide

This file contains project-specific patterns, conventions, and context for Claude to reference during development.

## Project Overview

- **Name**: Well-Cost-Management - Well Cost Management for Upstream Oil & Gas Companies
- **Purpose**: Manage and track costs associated with oil and gas well operations
- **Documentation**: Word to Markdown converter with document categorization

## Project Architecture

```
Well-Cost-Management/
├── converter/              # Word to Markdown converter module
│   ├── __init__.py
│   ├── config.py          # Configuration settings
│   └── word_to_markdown.py # Main converter script
├── docs/                   # Documentation output
│   ├── architecture/      # Architecture documents
│   ├── functional/        # Functional documents
│   ├── technical/         # Technical documents
│   ├── uploads/           # Word document uploads
│   └── design/            # Design documents (RACI, decisions, tracker)
├── templates/             # Markdown templates
│   ├── architecture_template.md
│   ├── functional_template.md
│   └── technical_template.md
├── GOVERNANCE.md          # Project governance framework
├── CLAUDE.md              # This file - development guide
├── requirements.txt       # Python dependencies
└── README.md              # Project documentation
```

## Document Categories

All documents are classified into three categories:

| Category | Description | Output Directory |
|----------|-------------|------------------|
| Architecture | System design, components, diagrams | `docs/architecture/` |
| Functional | Features, requirements, user stories | `docs/functional/` |
| Technical | Implementation, APIs, configurations | `docs/technical/` |

## Converter Usage

```bash
# Convert a Word document to Markdown
python -m converter.word_to_markdown <input.docx> -c <category>

# Categories: architecture, functional, technical
```

## Development Guidelines

### Before Starting Any Work

1. **Read GOVERNANCE.md** - Understand approval gates
2. **Check git status** - Know the current state
3. **Review docs/** - See available documentation
4. **Confirm with user** - Get approval before coding

### Code Quality Standards

- Follow PEP 8 for Python code
- Use type hints where appropriate
- Add docstrings to functions and classes
- Keep functions focused and small

### Git Workflow

1. Work on feature branches
2. Write clear commit messages
3. Get user approval before committing
4. Push to designated branch

### File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Python modules | snake_case.py | `word_to_markdown.py` |
| Markdown docs | UPPER_CASE.md or kebab-case.md | `GOVERNANCE.md`, `architecture_template.md` |
| Config files | lowercase | `config.py`, `requirements.txt` |

## Session Protocol

At the start of each session:

1. Read `GOVERNANCE.md` for current project rules
2. Check `git status` for uncommitted changes
3. Review recent changes in `git log`
4. Understand what's in `docs/` directory
5. Confirm gates before proposing work

## Common Tasks

### Adding a New Document Category

1. Create directory in `docs/`
2. Add `.gitkeep` file
3. Create template in `templates/`
4. Update `converter/config.py`
5. Update `converter/word_to_markdown.py`

### Modifying the Converter

1. Read existing code in `converter/`
2. Understand the current implementation
3. Propose changes to user
4. Implement after approval
5. Test with sample documents

## Error Handling

When errors occur:
1. Report the error clearly
2. Explain what was being attempted
3. Suggest solutions
4. Wait for user guidance

## Dependencies

Current dependencies (requirements.txt):
- python-docx>=0.8.11

## Related Documentation

- `GOVERNANCE.md` - Project governance and approval gates
- `docs/design/RACI.md` - Roles and responsibilities matrix
- `docs/design/DESIGN_DECISIONS.md` - Design decisions log
- `docs/design/PROJECT_TRACKER.md` - Project progress tracking

---

*Last Updated: January 2026*
*Adapted from FuelSphere Development Guide*
