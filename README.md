# Well-Cost-Management

Well Cost Management for Upstream Oil & Gas Companies

## Word to Markdown Converter

This project includes a Word to Markdown converter that supports three documentation categories:

- **Architecture Document**: System design, components, and architecture diagrams
- **Functional Document**: Features, requirements, and user stories
- **Technical Document**: Implementation details, APIs, and configurations

## Project Structure

```
Well-Cost-Management/
├── converter/
│   ├── __init__.py
│   ├── config.py
│   └── word_to_markdown.py
├── docs/
│   ├── architecture/      # Architecture documents output
│   ├── functional/        # Functional documents output
│   ├── technical/         # Technical documents output
│   └── uploads/           # Upload Word documents here
├── templates/
│   ├── architecture_template.md
│   ├── functional_template.md
│   └── technical_template.md
├── requirements.txt
└── README.md
```

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Well-Cost-Management
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Convert a Word Document to Markdown

```bash
python -m converter.word_to_markdown <input_file.docx> -c <category>
```

### Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `input` | Path to the Word document (.docx) | Yes |
| `-c, --category` | Document category (architecture, functional, technical) | Yes |
| `-o, --output` | Custom output filename (optional) | No |

### Examples

Convert an architecture document:
```bash
python -m converter.word_to_markdown docs/uploads/system_design.docx -c architecture
```

Convert a functional document with custom output name:
```bash
python -m converter.word_to_markdown docs/uploads/requirements.docx -c functional -o user_requirements
```

Convert a technical document:
```bash
python -m converter.word_to_markdown docs/uploads/api_spec.docx -c technical
```

## Document Categories

### Architecture Documents
Output: `docs/architecture/`

Used for:
- System architecture designs
- Component diagrams
- Infrastructure documentation
- Integration architectures
- Security architecture

### Functional Documents
Output: `docs/functional/`

Used for:
- Functional requirements
- User stories
- Use cases
- Business rules
- Process flows

### Technical Documents
Output: `docs/technical/`

Used for:
- API documentation
- Database schemas
- Code documentation
- Configuration guides
- Deployment procedures

## Templates

Pre-built templates are available in the `templates/` directory:

- `architecture_template.md` - Template for architecture documents
- `functional_template.md` - Template for functional documents
- `technical_template.md` - Template for technical documents

## Features

- Converts Word documents (.docx) to Markdown format
- Preserves document structure (headings, paragraphs, lists)
- Converts tables to Markdown table format
- Handles inline formatting (bold, italic)
- Generates YAML front matter with metadata
- Organizes output by document category

## License

MIT License
