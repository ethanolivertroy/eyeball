A tool to help verify AI statements.

When AI analyzes a document and tells you "Section 10 requires mutual indemnification," how do you know Section 10 actually says that? Eyeball lets you see for yourself.

This is a plugin for Cursor and GitHub Copilot. It generates document analyses as Word files with inline screenshots of relevant portions from the source material. Every factual claim in the analysis includes a highlighted screenshotted excerpt from the original document, so you can verify each assertion without switching between files or hunting for the right page.

![Sample Eyeball output showing analysis with highlighted source screenshot](docs/sample-output.png)
*Sample output using a synthetic vendor agreement. All names and terms are fictional.*

## What it does

You give Cursor or Copilot a document (Word file, PDF, or web URL) and ask it to analyze something specific. Eyeball reads the source, writes the analysis, and for each claim, captures a screenshot of the relevant section from the original document with the cited text highlighted in yellow. The output is a Word document on your Desktop with analysis text and source screenshots interleaved.

If the analysis says "Section 9.3 allows termination for cause with a 30-day cure period," the screenshot below it shows Section 9.3 from the actual document with that language highlighted. If the screenshot shows something different, the analysis is wrong and you can see it immediately.

## Installation

### Prerequisites

- [Cursor](https://cursor.com) or [Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- Python 3.8 or later
- One of the following for Word document support (PDFs and web URLs work without these):
  - Microsoft Word (macOS or Windows)
  - LibreOffice (any platform)

### Install in Cursor

1. In Cursor, open **Customize** in the sidebar.
2. Choose **From GitHub Repository** and enter `https://github.com/ethanolivertroy/eyeball`.
3. Install **Eyeball** and choose a user or project scope.
4. In Agent chat, type `/eyeball`. The skill should appear in the list.

The Python dependencies install the first time you use Eyeball (see [Install dependencies](#install-dependencies)). Word documents also need Microsoft Word or LibreOffice.

On Teams and Enterprise plans, this repo can also be added as a team marketplace from **Dashboard > Plugins & MCPs** (**Add Marketplace**, then **Import from Repo**).

**As a personal skill**

To use the skill without installing the plugin, copy it into your Cursor skills folder and install the dependencies from the clone:

```bash
git clone https://github.com/ethanolivertroy/eyeball.git
mkdir -p ~/.cursor/skills
rm -rf ~/.cursor/skills/eyeball
cp -R eyeball/plugins/eyeball/skills/eyeball ~/.cursor/skills/eyeball
bash eyeball/plugins/eyeball/setup.sh
```

Copy the folder instead of linking it, because Cursor skips skill folders that are symlinks. Reload Cursor, and Eyeball appears under **Customize > Skills**.

If you open this repo itself in Cursor, the skill loads from `.cursor/skills/eyeball` without installing the plugin.

### Install in GitHub Copilot

Point Copilot CLI at this repo and ask it to install the plugin:

```
Install the plugin at github.com/ethanolivertroy/eyeball for me.
```

Or install via the Copilot CLI plugin system, or clone the repo:

```bash
git clone https://github.com/ethanolivertroy/eyeball.git
```

### Install dependencies

The first time you use Eyeball, the agent checks its dependencies. If the source type you asked for isn't ready, the agent runs the setup script that ships with the plugin. The script installs the Python packages and Playwright's Chromium browser (for web pages). It does not install Word or LibreOffice.

To run setup yourself from a clone of this repo:

**macOS / Linux:**

```bash
cd eyeball
bash setup.sh
```

**Windows (PowerShell):**

```powershell
cd eyeball
.\setup.ps1
```

**Manual install (any platform):**

```bash
pip install pymupdf pillow python-docx playwright
python -m playwright install chromium
```

On Windows, `pywin32` is also needed for Microsoft Word automation and is installed automatically by the setup script.

### Verify setup

```bash
python3 plugins/eyeball/skills/eyeball/tools/eyeball.py setup-check
```

The "Source support" lines at the end show which source types work on your machine. The dependency list always shows at least one Word entry as missing, because it checks for Word on both macOS and Windows. For Word documents, either Word or LibreOffice is enough.

## How to use it

In Cursor Agent chat, type `/eyeball` or ask in plain language. In a Copilot CLI conversation, tell it to use eyeball. Examples:

```
use eyeball on ~/Desktop/vendor-agreement.docx -- analyze the indemnification
and liability provisions and flag anything unusual
```

```
run eyeball on https://example.com/terms-of-service -- identify the
developer-friendly aspects of these terms
```

```
use eyeball to analyze this NDA for non-compete provisions
```

Eyeball activates, reads the source document, writes the analysis with exact section references, and generates a Word document on your Desktop with source screenshots inline.

## What it supports

| Source type | Requirements |
|---|---|
| PDF files | Python + PyMuPDF (included in setup) |
| Web pages | Python + Playwright + Chromium (included in setup) |
| Word documents (.docx) | Microsoft Word (macOS/Windows) or LibreOffice (any platform). On Windows, pywin32 is also required (included in setup). |

## How it works

1. Eyeball reads the full text of the source document
2. It writes analysis with exact section numbers, page references, and verbatim quotes
3. For each claim, it searches the rendered source for the cited text
4. It captures a screenshot of the surrounding region with the cited text highlighted in yellow
5. It assembles a Word document with analysis paragraphs and screenshots interleaved
6. The output lands on your Desktop

The screenshots are dynamically sized: if a section of analysis references text that spans a large region, the screenshot expands to cover it. If the referenced text appears on multiple pages, the screenshots are stitched together.

## Why screenshots instead of quoted text?

In hallucination-sensitive contexts, sometimes we need to see receipts.

Quoted text is easy to fabricate. A model can generate a plausible-sounding quote that doesn't actually appear in the source, and without checking, you'd never know. Screenshots from the rendered source are harder to fake; they show the actual formatting, layout, and surrounding context of the original document. You can see at a glance whether the highlighted text matches the claim, and the surrounding text provides context that a cherry-picked quote might omit.

## Limitations

- Word document conversion requires Microsoft Word or LibreOffice. Without one of these, you can still use Eyeball with PDFs and web URLs.
- Text search is string-matching. If the source document uses unusual encoding, ligatures, or non-standard characters, some searches may not match. The skill instructions tell the AI to use verbatim phrases from the extracted text, which handles most cases.
- Web page rendering depends on Playwright and may not perfectly capture all dynamic content (e.g., content loaded by JavaScript after page load, content behind login walls).
- Screenshot quality depends on the source formatting. Dense multi-column layouts or very small text may produce less readable screenshots. Increase the DPI setting if needed.

## Development

### Repository layout

Cursor and Copilot load the same skill from `plugins/eyeball`.

```text
.cursor-plugin/marketplace.json   Marketplace manifest Cursor reads when you import the repo
.github/plugin/plugin.json        Copilot plugin manifest
.cursor/skills/eyeball/           Copy of the skill, loaded when this repo is open in Cursor
plugins/eyeball/                  The plugin folder Cursor installs
├── .cursor-plugin/plugin.json    Cursor plugin manifest
├── skills/eyeball/               The skill: SKILL.md and tools/eyeball.py
├── setup.sh, setup.ps1           Dependency setup
└── requirements.txt
setup.sh, setup.ps1               Wrappers that run the plugin's setup scripts
requirements.txt                  Includes plugins/eyeball/requirements.txt
docs/                             Sample output and the checked sample below
```

### Editing the skill

Edit the skill in `plugins/eyeball/skills/eyeball`, then copy it to `.cursor/skills/eyeball`:

```bash
rm -rf .cursor/skills/eyeball
cp -R plugins/eyeball/skills/eyeball .cursor/skills/eyeball
```

The two folders must match. The copy is a real folder rather than a symlink, because Cursor skips skill folders that are symlinks. The repo-root `setup.sh` and `setup.ps1` stop with an error if the copies differ.

### Testing the plugin locally

To try the plugin the way Cursor installs it, copy `plugins/eyeball` to `~/.cursor/plugins/local/eyeball` and run **Developer: Reload Window**. Copy the folder rather than linking it, because Cursor only loads a symlink there when the target is inside that folder. On Teams and Enterprise, admins control local plugins with **Allow Local Plugin Imports**, which is off by default on Enterprise. If Eyeball is also installed from a marketplace, that install takes precedence over the local copy. See the [Cursor plugins docs](https://cursor.com/docs/plugins).

### Checked sample

`docs/sample-analysis/` holds a one-page synthetic PDF and the Word file Eyeball built from it. The analysis cites "30-day cure period", and the docx embeds a screenshot of that phrase from the PDF. Regenerate it with:

```bash
python3 plugins/eyeball/skills/eyeball/tools/eyeball.py extract-text \
  --source docs/sample-analysis/source.pdf
python3 plugins/eyeball/skills/eyeball/tools/eyeball.py build \
  --source docs/sample-analysis/source.pdf \
  --output docs/sample-analysis/analysis.docx \
  --title "Sample analysis" \
  --subtitle "Synthetic one-page source" \
  --sections '[{"heading":"1. Termination","analysis":"Section 9.3 allows termination for cause with a 30-day cure period.","anchors":["30-day cure period"],"target_page":1}]'
```

## License

MIT
