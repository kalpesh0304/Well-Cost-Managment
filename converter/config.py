"""
Configuration settings for the Word to Markdown converter.
"""

from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).parent.parent

# Document directories
DOCS_DIR = BASE_DIR / "docs"
UPLOADS_DIR = DOCS_DIR / "uploads"
TEMPLATES_DIR = BASE_DIR / "templates"

# Output directories by category
OUTPUT_DIRS = {
    "architecture": DOCS_DIR / "architecture",
    "functional": DOCS_DIR / "functional",
    "technical": DOCS_DIR / "technical",
}

# Supported file extensions
SUPPORTED_EXTENSIONS = [".docx"]

# Document categories
DOCUMENT_CATEGORIES = [
    "architecture",
    "functional",
    "technical",
]

# Category descriptions
CATEGORY_DESCRIPTIONS = {
    "architecture": "System design, components, and architecture diagrams",
    "functional": "Features, requirements, and user stories",
    "technical": "Implementation details, APIs, and configurations",
}
