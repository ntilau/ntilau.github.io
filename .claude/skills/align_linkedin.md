# align_linkedin Skill

This skill provides guidance on using the `align_linkedin.py` tool to compare your LinkedIn profile with your CV data extracted from `my.tex` and `cv.tex`.

## Purpose

The `align_linkedin.py` script helps you ensure your LinkedIn profile stays consistent with your CV by:
- Parsing your CV LaTeX source (`my.tex` + `cv.tex`) into a structured profile
- Comparing against either:
  - A LinkedIn data export (CSV files from "Download Your Data")
  - A live scraped LinkedIn profile (requires Playwright)
- Reporting discrepancies in sections like headline, summary, positions, projects, skills, languages, education, certifications, courses, publications, and awards.

## Usage

Run the script from the repository root:

```bash
python align_linkedin.py [options]
```

### Modes

1. **View CV summary** (default)
   ```bash
   python align_linkedin.py
   ```
   Parses your CV and prints a formatted summary of all sections.

2. **Compare against LinkedIn data export**
   ```bash
   python align_linkedin.py --linkedin-dir /path/to/linkedin/export
   ```
   Compares your CV against CSV files extracted from LinkedIn's "Download Your Data" archive.
   Expected CSV files: `Positions.csv`, `Education.csv`, `Skills.csv`, `Languages.csv`, `Certifications.csv`, `Publications.csv`, `Patents.csv`, `Honors.csv`, `Courses.csv`, `Projects.csv`, `Profile.csv`.

3. **Scrape LinkedIn profile and compare**
   ```bash
   python align_linkedin.py --scrape [profile-url]
   ```
   Uses Playwright to scrape your live LinkedIn profile (first run requires manual login).
   If no URL is provided, uses the LinkedIn handle from `my.tex`.
   Note: Scraping requires:
   ```bash
   pip install playwright && playwright install chromium
   ```

4. **Dump CV data as JSON**
   ```bash
   python align_linkedin.py --json
   ```
   Outputs the parsed CV profile as JSON for manual review or debugging.

5. **Enable debugging for scraping**
   ```bash
   python align_linkedin.py --scrape --debug
   ```
   Saves screenshot, HTML, and raw text of the scraped page to debug selector issues.

## Interpreting Output

The script prints a report titled "LinkedIn Alignment Report" with a list of discrepancies (if any). Each discrepancy is prefixed with a section tag:

- `[HEADLINE]` - Headline/tagline mismatch
- `[SUMMARY]` - Missing or mismatched summary
- `[POSITION]` - Position (job) not found on LinkedIn or missing description
- `[PROJECT]` - Project entry not found on LinkedIn
- `[SKILL]` - Skill missing from LinkedIn skills list
- `[LANGUAGE]` - Language missing from LinkedIn languages
- `[EDUCATION]` - Education entry not found on LinkedIn
- `[CERTIFICATION]` - Certification not found in LinkedIn export
- `[COURSE]` - Course not found in LinkedIn export
- `[PUBLICATION]` - Publication not found in LinkedIn export
- `[AWARD]` - Award/honor not found in LinkedIn export

If no discrepancies are found, the script prints:
```
✓ LinkedIn profile is aligned with CV. No discrepancies found.
```

## Common Workflows

### Quarterly Alignment Check
1. Run `python align_linkedin.py --scrape` to compare against your live profile.
2. Review any discrepancies reported.
3. Update your LinkedIn profile (or CV) as needed to resolve mismatches.
4. Re-run to verify alignment.

### Using LinkedIn Data Export
1. Request your LinkedIn data: Settings > Data Privacy > Get a copy of your data.
2. Select "CSV" format and request the archive.
3. Once downloaded, extract the zip file.
4. Run `python align_linkedin.py --linkedin-dir /path/to/extracted/archive`.
5. Address any reported discrepancies.

## Troubleshooting

### Scraping Issues
- **First run**: A Chrome window will open for you to log into LinkedIn manually. After logging in, the script will wait for the profile to load.
- **Subsequent runs**: Uses persistent session stored in `~/.linkedin_align_profile`.
- **If scraping fails**: Ensure Playwright is installed correctly (`pip install playwright && playwright install chromium`).
- **Debugging**: Use `--scrape --debug` to save diagnostic files.

### CSV Export Issues
- Ensure you're pointing to the directory containing the CSV files, not the zip archive itself.
- Some LinkedIn exports may use different encodings; the script handles UTF-8 with BOM (`utf-8-sig`).

## Integration with CV Workflow

Since your CV is built with LaTeX via `make cv`, you can integrate alignment checks:

```bash
# Build CV PDF
make cv

# Check LinkedIn alignment
python align_linkedin.py --scrape
```

## Related Commands

- `make cv` - Build your CV PDF
- `make cl` - Build your cover letter PDF
- `make all` - Build both CV and cover letter
- `make clean` - Remove auxiliary LaTeX files

---

*Skill automatically loaded when working with LinkedIn alignment tasks in this repository.*