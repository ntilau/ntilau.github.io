"""
Align LinkedIn profile with CV data extracted from my.tex / cv.tex.

Usage:
  python align_linkedin.py                     # parse CV, print structured summary
  python align_linkedin.py --linkedin-dir <path>  # compare CV against LinkedIn data export
  python align_linkedin.py --scrape [profile-url]  # scrape LinkedIn profile and compare
  python align_linkedin.py --json                  # dump CV data as JSON (for manual review)

Scraping requires: pip install playwright && playwright install chromium
"""

import argparse
import csv
import json
import os
import re
import unicodedata
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

@dataclass
class Position:
    title: str
    company: str
    start: str      # MM/YYYY
    end: str        # MM/YYYY or "Present"
    location: str
    description: list[str] = field(default_factory=list)

@dataclass
class Education:
    degree: str
    school: str
    start: str
    end: str
    location: str
    notes: str = ""

@dataclass
class Award:
    title: str
    issuer: str
    date: str

@dataclass
class Certification:
    title: str
    issuer: str

@dataclass
class Course:
    title: str
    provider: str
    date: str
    location: str

@dataclass
class Publication:
    title: str
    authors: str
    venue: str
    year: str
    pub_type: str  # article, inproceedings, book, patent

@dataclass
class Language:
    name: str
    level: int  # 1-5

@dataclass
class Recommendation:
    author: str
    role: str
    date: str
    location: str
    text: str

@dataclass
class CVProfile:
    name: str
    headline: str
    email: str
    location: str
    linkedin: str
    github: str
    summary: str
    positions: list[Position] = field(default_factory=list)
    education: list[Education] = field(default_factory=list)
    awards: list[Award] = field(default_factory=list)
    certifications: list[Certification] = field(default_factory=list)
    courses: list[Course] = field(default_factory=list)
    publications: list[Publication] = field(default_factory=list)
    languages: list[Language] = field(default_factory=list)
    skills: list[str] = field(default_factory=list)
    recommendations: list[Recommendation] = field(default_factory=list)


# ---------------------------------------------------------------------------
# .tex parser
# ---------------------------------------------------------------------------

def _tex_strip(s: str) -> str:
    """Strip LaTeX commands/braces from a string."""
    s = re.sub(r'\\href\{[^}]*\}\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\printinfo\{[^}]*\}\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\[a-zA-Z]+(\[[^\]]*\])?(\{[^}]*\})?', '', s)
    s = s.replace('{', '').replace('}', '')
    s = re.sub(r'\s+', ' ', s).strip()
    return s

def _parse_date(tex_date: str) -> str:
    """Convert LaTeX date like 03/2022 -- Present to normalised MM/YYYY."""
    tex_date = tex_date.strip()
    tex_date = re.sub(r'\\/\\s*', '/', tex_date)
    tex_date = tex_date.replace('\\', '')
    return tex_date


def _parse_date_range(dates: str) -> tuple[str, str]:
    """Parse a date range like '03/2022 -- Present' or '05/2018 - 12/2018'."""
    parts = re.split(r'\s*[-–—]{1,3}\s*', dates.strip())
    start = _parse_date(parts[0].strip()) if len(parts) >= 1 else ''
    end = _parse_date(parts[1].strip()) if len(parts) >= 2 else ''
    return start, end

def _clean_desc(line: str) -> str:
    """Clean a bullet-point description line."""
    line = re.sub(r'%.*$', '', line)  # strip comments
    line = _tex_strip(line)
    line = line.strip().lstrip('-').strip()
    return line

def _extract_braced_block(text: str, cmd: str) -> str:
    """Extract content of \\cmd{...} handling nested braces."""
    start = text.find(f'\\{cmd}{{')
    if start == -1:
        return ''
    pos = start + len(cmd) + 2  # past \{ and {
    depth = 1
    end = pos
    while end < len(text) and depth > 0:
        if text[end] == '{':
            depth += 1
        elif text[end] == '}':
            depth -= 1
        end += 1
    return text[pos:end - 1] if depth == 0 else ''


def parse_my_tex(path: str) -> dict:
    """Extract personal info and config from my.tex."""
    with open(path) as f:
        content = f.read()

    data = {}
    data['name'] = _tex_strip(re.search(r'\\name\{([^}]*)\}', content).group(1))
    data['headline'] = _tex_strip(re.search(r'\\tagline\{([^}]*)\}', content).group(1))

    pi_text = _extract_braced_block(content, 'personalinfo')
    if pi_text:
        email_m = re.search(r'\\printinfo\{\\faAt\}\{([^}]*)\}', pi_text)
        data['email'] = _tex_strip(email_m.group(1)) if email_m else ''
        li_m = re.search(r'\\linkedin\{([^}]*)\}', pi_text)
        data['linkedin'] = _tex_strip(li_m.group(1)) if li_m else ''
        gh_m = re.search(r'\\github\{([^}]*)\}', pi_text)
        data['github'] = _tex_strip(gh_m.group(1)) if gh_m else ''
        loc_match = re.search(r'\\location\{([^}]*)\}', pi_text)
        data['location'] = _tex_strip(loc_match.group(1)) if loc_match else ""

    return data


def parse_cv_tex(path: str) -> CVProfile:
    """Extract full CV data from cv.tex (with my.tex preamble)."""
    with open(path) as f:
        content = f.read()

    # --- summary ---
    summary_match = re.search(
        r'\\cvsection\{Summary\}\s*\n\s*(.*?)\n\s*\\medskip', content, re.DOTALL
    )
    summary = ""
    if summary_match:
        summary = ' '.join(line.strip() for line in summary_match.group(1).strip().splitlines()
                           if line.strip() and not line.strip().startswith('%'))

    # --- positions (Experience section) ---
    positions = []
    exp_section = re.search(
        r'\\cvsection\{Experience\}\s*\n(.*?)(?=\\cvsection\{Projects\})',
        content, re.DOTALL
    )
    if exp_section:
        exp_text = exp_section.group(1)
        for m in re.finditer(
            r'\\cvevent\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\s*\n\s*\\begin\{itemize\}\s*\n(.*?)\\end\{itemize\}',
            exp_text, re.DOTALL
        ):
            title, company, dates, location = m.group(1), m.group(2), m.group(3), m.group(4)
            desc_block = m.group(5)
            bullets = []
            clean_block = re.sub(r'^\s*%.*$', '', desc_block, flags=re.MULTILINE)
            for item in re.finditer(r'^[ \t]*\\item\s+(.*?)(?=\n[ \t]*\\item|\n[ \t]*\\end|\s*$)', clean_block, re.MULTILINE | re.DOTALL):
                bullets.append(_clean_desc(item.group(1)))
            positions.append(Position(
                title=_tex_strip(title),
                company=_tex_strip(company),
                start=_parse_date_range(dates)[0],
                end=_parse_date_range(dates)[1],
                location=_tex_strip(location),
                description=bullets,
            ))

    # --- projects ---
    proj_section = re.search(
        r'\\cvsection\{Projects\}\s*\n(.*?)(?=\\switchcolumn)',
        content, re.DOTALL
    )
    if proj_section:
        proj_text = proj_section.group(1)
        for m in re.finditer(
            r'\\cvevent\{(?:\\href\{[^}]*\}\{)?([^}]*(?:\}[^}]*)?)\}\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\s*\n\s*\\begin\{itemize\}\s*\n(.*?)\\end\{itemize\}',
            proj_text, re.DOTALL
        ):
            title = _tex_strip(m.group(1))
            company = _tex_strip(m.group(2)) or "Various"
            dates = m.group(3)
            location = _tex_strip(m.group(4))
            desc_block = m.group(5)
            bullets = []
            clean_block = re.sub(r'^\s*%.*$', '', desc_block, flags=re.MULTILINE)
            for item in re.finditer(r'^[ \t]*\\item\s+(.*?)(?=\n[ \t]*\\item|\n[ \t]*\\end|\s*$)', clean_block, re.MULTILINE | re.DOTALL):
                bullets.append(_clean_desc(item.group(1)))
            positions.append(Position(
                title=title,
                company=company,
                start=_parse_date_range(dates)[0],
                end=_parse_date_range(dates)[1],
                location=location,
                description=bullets,
            ))

    # --- education ---
    education = []
    edu_section = re.search(
        r'\\cvsection\{Education\}\s*\n(.*?)(?=\\cvsection\{Awards\})',
        content, re.DOTALL
    )
    if edu_section:
        edu_text = edu_section.group(1)
        for m in re.finditer(
            r'\\cvevent\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}',
            edu_text
        ):
            degree, school, dates, location = m.group(1), m.group(2), m.group(3), m.group(4)
            # Get trailing text before next \divider or \cvevent
            end_pos = m.end()
            next_block = re.search(r'\\divider|\\cvevent|\\cvsection', edu_text[end_pos:])
            notes = edu_text[end_pos:end_pos + (next_block.start() if next_block else 0)].strip()
            education.append(Education(
                degree=_tex_strip(degree),
                school=_tex_strip(school),
                start=_parse_date_range(dates)[0],
                end=_parse_date_range(dates)[1],
                location=_tex_strip(location),
                notes=_tex_strip(notes),
            ))

    # --- awards ---
    awards = []
    aw_section = re.search(
        r'\\cvsection\{Awards\}\s*\n(.*?)(?=\\cvsection\{Certifications\})',
        content, re.DOTALL
    )
    if aw_section:
        aw_text = aw_section.group(1)
        for m in re.finditer(
            r'\\cvachievement\{\\fa[A-Za-z]+\}\{([^}]*)\}\{([^}]*)\}',
            aw_text
        ):
            awards.append(Award(
                title=_tex_strip(m.group(1)),
                issuer="",  # embedded in title text
                date=_tex_strip(m.group(2)),
            ))

    # --- certifications ---
    certs = []
    cert_section = re.search(
        r'\\cvsection\{Certifications\}\s*\n(.*?)(?=\\cvsection\{Courses\})',
        content, re.DOTALL
    )
    if cert_section:
        cert_text = cert_section.group(1)
        for m in re.finditer(
            r'\\cvachievement\{\\fa[A-Za-z]+\}\{([^}]*)\}\{([^}]*)\}',
            cert_text
        ):
            certs.append(Certification(
                title=_tex_strip(m.group(1)),
                issuer=_tex_strip(m.group(2)),
            ))

    # --- courses ---
    courses = []
    course_section = re.search(
        r'\\cvsection\{Courses\}\s*\n(.*?)(?=\\cvsection\{Skills\})',
        content, re.DOTALL
    )
    if course_section:
        course_text = course_section.group(1)
        for m in re.finditer(
            r'\\cvevent\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}',
            course_text
        ):
            courses.append(Course(
                title=_tex_strip(m.group(1)),
                provider=_tex_strip(m.group(2)),
                date=_tex_strip(m.group(3)),
                location=_tex_strip(m.group(4)),
            ))

    # --- skills ---
    skills = []
    skill_section = re.search(
        r'\\cvsection\{Skills\}\s*\n(.*?)(?=\\cvsection\{Languages\})',
        content, re.DOTALL
    )
    if skill_section:
        sec_text = re.sub(r'^\s*%.*$', '', skill_section.group(1), flags=re.MULTILINE)
        for m in re.finditer(r'\\cvtag\{([^}]*)\}', sec_text):
            skills.append(_tex_strip(m.group(1)))

    # --- languages ---
    languages = []
    lang_section = re.search(
        r'\\cvsection\{Languages\}\s*\n(.*?)(?=\\cvsection\{Publications\})',
        content, re.DOTALL
    )
    if lang_section:
        for m in re.finditer(
            r'\\cvskill\{([^}]*)\}\{([0-9.]+)\}',
            lang_section.group(1)
        ):
            languages.append(Language(
                name=_tex_strip(m.group(1)),
                level=int(float(m.group(2))),
            ))

    # --- publications (from my.bib in same dir as cv.tex) ---
    publications = []
    bib_path = Path(path).parent / "my.bib"
    if bib_path.exists():
        publications = parse_bib(str(bib_path))

    # --- recommendations ---
    recommendations = []
    rec_section = re.search(
        r'\\cvsection\{Recommendations\}\s*\n(.*?)(?=\\end\{paracol\})',
        content, re.DOTALL
    )
    if rec_section:
        rec_text = rec_section.group(1)
        for m in re.finditer(
            r'\\cvevent\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}\s*\\begin\{quotation\}\s*(.*?)\\end\{quotation\}',
            rec_text, re.DOTALL
        ):
            recommendations.append(Recommendation(
                author=_tex_strip(m.group(1)),
                role=_tex_strip(m.group(2)),
                date=_tex_strip(m.group(3)),
                location=_tex_strip(m.group(4)),
                text=_tex_strip(m.group(5)).strip('"').strip("'").strip(),
            ))

    return CVProfile(
        name="", headline="", email="", location="", linkedin="", github="", summary=summary,
        positions=positions, education=education, awards=awards,
        certifications=certs, courses=courses, publications=publications,
        languages=languages, skills=skills, recommendations=recommendations,
    )


def parse_bib(path: str) -> list[Publication]:
    """Parse BibTeX file into Publication list."""
    with open(path) as f:
        content = f.read()

    pubs = []
    for m in re.finditer(
        r'@(\w+)\{([^,]*),\s*\n(.*?)\n\}',
        content, re.DOTALL
    ):
        pub_type = m.group(1).lower()
        body = m.group(3)
        fields = {}
        for fld in re.finditer(r'(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}', body):
            fields[fld.group(1).lower()] = _tex_strip(fld.group(2))

        title = fields.get('title', '')
        author = fields.get('author', '')
        journal = fields.get('journal', '')
        booktitle = fields.get('booktitle', '')
        venue = journal or booktitle or ''
        year = fields.get('year', '')

        if pub_type == 'patent':
            venue = fields.get('organization', '')
            title = fields.get('title', '')

        pubs.append(Publication(
            title=title,
            authors=author,
            venue=venue,
            year=year,
            pub_type=pub_type,
        ))

    return pubs


def build_profile(base_dir: str) -> CVProfile:
    """Build a complete CVProfile from my.tex + cv.tex."""
    my_path = Path(base_dir) / "my.tex"
    cv_path = Path(base_dir) / "cv.tex"

    if not my_path.exists() or not cv_path.exists():
        print(f"Error: {my_path} and {cv_path} must both exist.")
        sys.exit(1)

    personal = parse_my_tex(str(my_path))
    profile = parse_cv_tex(str(cv_path))

    profile.name = personal.get('name', '')
    profile.headline = personal.get('headline', '')
    profile.email = personal.get('email', '')
    profile.location = personal.get('location', '')
    profile.linkedin = personal.get('linkedin', '')
    profile.github = personal.get('github', '')

    return profile


# ---------------------------------------------------------------------------
# LinkedIn data export reader
# ---------------------------------------------------------------------------

def read_linkedin_export(linkedin_dir: str) -> dict:
    """Read LinkedIn 'Download Your Data' CSV files. Returns structured dict."""
    ldir = Path(linkedin_dir)
    data = {}

    # Positions.csv
    pos_file = ldir / "Positions.csv"
    if pos_file.exists():
        data['positions'] = []
        with open(pos_file, encoding='utf-8-sig') as f:
            for row in csv.DictReader(f):
                data['positions'].append({
                    'title': row.get('Title', ''),
                    'company': row.get('Company Name', ''),
                    'start': _normalise_linkedin_date(row.get('Started On', '')),
                    'end': _normalise_linkedin_date(row.get('Finished On', '')) or 'Present',
                    'location': row.get('Location', ''),
                    'description': row.get('Description', ''),
                })

    # Education.csv
    edu_file = ldir / "Education.csv"
    if edu_file.exists():
        data['education'] = []
        with open(edu_file, encoding='utf-8-sig') as f:
            for row in csv.DictReader(f):
                data['education'].append({
                    'degree': row.get('Degree Name', '') or row.get('Degree', ''),
                    'school': row.get('School Name', ''),
                    'start': _normalise_linkedin_date(row.get('Start Date', '')),
                    'end': _normalise_linkedin_date(row.get('End Date', '')),
                    'notes': row.get('Notes', ''),
                })

    # Skills.csv
    skills_file = ldir / "Skills.csv"
    if skills_file.exists():
        data['skills'] = []
        with open(skills_file, encoding='utf-8-sig') as f:
            for row in csv.DictReader(f):
                data['skills'].append(row.get('Name', ''))

    # Languages.csv (if exists)
    lang_file = ldir / "Languages.csv"
    if lang_file.exists():
        data['languages'] = []
        with open(lang_file, encoding='utf-8-sig') as f:
            for row in csv.DictReader(f):
                data['languages'].append({
                    'name': row.get('Name', ''),
                    'proficiency': row.get('Proficiency', ''),
                })

    # Profile.csv
    prof_file = ldir / "Profile.csv"
    if prof_file.exists():
        with open(prof_file, encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            for row in reader:
                data['headline'] = row.get('Headline', '')
                data['summary'] = row.get('Summary', '')
                break

    return data


def _normalise_linkedin_date(d: str) -> str:
    """Convert LinkedIn date formats to MM/YYYY."""
    if not d:
        return ''
    for fmt in ('%Y-%m-%d', '%Y-%m', '%b %Y', '%B %Y', '%m/%Y', '%m/%d/%Y'):
        try:
            dt = datetime.strptime(d.strip(), fmt)
            return dt.strftime('%m/%Y')
        except ValueError:
            continue
    return d.strip()


# ---------------------------------------------------------------------------
# LinkedIn profile scraper (Playwright-based)
# ---------------------------------------------------------------------------

class LinkedInScraper:
    """Scrape a LinkedIn profile page using Playwright with persistent session."""

    def __init__(self, profile_url: str, headless: bool = True):
        self.profile_url = profile_url.rstrip("/")
        self.headless = headless
        self.browser = None
        self.page = None

    async def _launch(self):
        from playwright.async_api import async_playwright

        self._pw = await async_playwright().start()

        user_data_dir = os.path.join(os.path.expanduser("~"), ".linkedin_align_profile")
        self.browser = await self._pw.chromium.launch_persistent_context(
            user_data_dir=user_data_dir,
            headless=False,  # must be visible for first-time login
            channel="chrome",
            args=["--no-sandbox"],
        )


    async def scrape(self, debug: bool = False) -> dict:
        """Scrape profile and return structured data dict."""
        await self._launch()
        self.page = self.browser.pages[0] if self.browser.pages else await self.browser.new_page()
        await self.page.set_viewport_size({"width": 1280, "height": 900})

        await self.page.goto(self.profile_url, wait_until="domcontentloaded")
        await self.page.wait_for_timeout(4000)

        # Check if we're seeing the public/logged-out view
        join_text = await self._text("h1:has-text('Join to view')")
        signin_text = await self._text("a:has-text('Sign in')")
        if join_text or signin_text or "login" in self.page.url or "authwall" in self.page.url:
            print(
                "\n  First run — log in to LinkedIn in the opened Chrome window."
                "\n  Waiting for login (timeout: 5 minutes)..."
            )
            # Poll until logged-in profile content appears
            for i in range(90):  # 90 * 10s = 15 min
                await self.page.wait_for_timeout(10000)
                await self.page.goto(self.profile_url, wait_until="domcontentloaded")
                await self.page.wait_for_timeout(2000)
                # Check for profile content (not login/join wall, not 2FA)
                has_title = await self._text("h1")
                has_join = await self._text("h1:has-text('Join to view')")
                is_login = "login" in self.page.url
                is_2fa = "verification" in self.page.url.lower() or "challenge" in self.page.url.lower()
                if has_title and not has_join and not is_login and not is_2fa:
                    print(f"  Logged in (attempt {i+1}). Proceeding...")
                    break
            else:
                print("  Login timed out. Re-run when logged in.")
                await self.browser.close()
                await self._pw.stop()
                return {}
            # Give the profile page time to fully render
            await self.page.wait_for_timeout(5000)

        if debug:
            await self.page.screenshot(path="debug_screenshot.png", full_page=True)
            main_text = await self.page.evaluate(
                "() => document.querySelector('main')?.innerText || document.body.innerText"
            )
            with open("debug_page_text.txt", "w") as f:
                f.write(main_text)
            html = await self.page.content()
            with open("debug_page.html", "w") as f:
                f.write(html)
            print("Debug files saved: debug_screenshot.png, debug_page_text.txt, debug_page.html")

        # Scroll to load lazy sections
        await self._expand_sections()

        # Extract full page text and parse it — more robust than CSS selectors
        full_text = ""
        try:
            full_text = await self.page.evaluate(
                "() => document.querySelector('main')?.innerText || document.body.innerText || ''"
            )
        except Exception:
            pass

        if not full_text:
            print("Could not extract page text.")
            await self.browser.close()
            await self._pw.stop()
            return {}

        data = self._parse_profile_text(full_text)
        data["positions"] = data.get("positions", [])
        data["education"] = data.get("education", [])
        data["skills"] = data.get("skills", [])
        data["languages"] = data.get("languages", [])

        await self.browser.close()
        await self._pw.stop()
        return data

    async def _text(self, selector: str) -> str:
        try:
            el = await self.page.wait_for_selector(selector, timeout=5000)
            return (await el.inner_text()).strip()
        except Exception:
            return ""

    async def _text_any(self, selectors: list[str]) -> str:
        for sel in selectors:
            t = await self._text(sel)
            if t:
                return t
        return ""

    def _parse_profile_text(self, text: str) -> dict:
        """Parse LinkedIn profile page innerText into structured data."""
        data = {"headline": "", "summary": "", "location": "", "positions": [],
                "education": [], "skills": [], "languages": []}
        lines = [l.strip() for l in text.split("\n") if l.strip()]

        if not lines:
            return data

        # --- name is lines[0] ---
        # headline is lines[1] (e.g. "Engineering | Simulations, Testing | Authoring")
        # location is lines[2] (contains "·" or "Contact Info")
        # connection count in lines[3] or [4]

        if len(lines) >= 2:
            data["headline"] = lines[1]
        for i, line in enumerate(lines[:5]):
            if "contact info" in line.lower() or "followers" in line.lower() or ("·" in line and i >= 2):
                data["location"] = line
                break

        # --- Sections ---
        sections = self._split_sections(lines)
        data["summary"] = sections.get("about", "")
        data["positions"] = self._parse_experience_text(sections.get("experience", ""))
        data["education"] = self._parse_education_text(sections.get("education", ""))
        data["skills"] = self._parse_skills_text(sections.get("skills", ""))
        data["languages"] = self._parse_languages_text(sections.get("languages", ""))

        return data

    def _split_sections(self, lines: list[str]) -> dict[str, str]:
        """Split innerText into named sections."""
        sections = {}
        current_section = None
        current_lines = []

        section_markers = [
            "about", "experience", "education", "featured",
            "licenses & certifications", "skills", "languages",
            "honors & awards", "publications", "recommendations",
            "interests", "activity", "people also viewed",
        ]

        for line in lines[3:]:  # skip name/headline/location
            low = line.strip().lower()
            # Section headers are typically short and match known markers
            if low in section_markers and len(line) < 40:
                if current_section:
                    sections[current_section] = "\n".join(current_lines)
                current_section = low.replace(" & ", "_").replace(" ", "_")
                current_lines = []
            elif current_section:
                current_lines.append(line)

        if current_section:
            sections[current_section] = "\n".join(current_lines)

        return sections

    def _parse_experience_text(self, text: str) -> list[dict]:
        """Parse experience section text into positions."""
        if not text:
            return []
        lines = text.strip().split("\n")
        positions = []

        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if not line:
                i += 1
                continue
            # A position typically starts with a company name followed by title
            # Detect: company name, then title on next line, then date range
            # Company lines are usually 1-3 words, title is longer
            if i + 1 < len(lines) and len(line) < 60:
                company = line
                title = lines[i + 1].strip() if not self._is_date_line(lines[i + 1]) else ""
                date_range = ""
                if i + 2 < len(lines) and self._is_date_line(lines[i + 2]):
                    date_range = lines[i + 2].strip()
                desc_lines = []
                j = i + (2 if title else 1) + (1 if date_range else 0)
                while j < len(lines) and not self._looks_like_company_start(lines[j], lines[j:j+3]):
                    if self._is_date_line(lines[j]):
                        j += 1
                        continue
                    desc_lines.append(lines[j])
                    j += 1
                positions.append({
                    "title": title,
                    "company": company,
                    "date_range": date_range,
                    "description": " ".join(desc_lines),
                })
                i = j
            else:
                i += 1
        return positions

    def _parse_education_text(self, text: str) -> list[dict]:
        if not text:
            return []
        lines = text.strip().split("\n")
        edu = []
        i = 0
        while i < len(lines):
            school = lines[i].strip()
            degree = lines[i + 1].strip() if i + 1 < len(lines) else ""
            date_range = lines[i + 2].strip() if i + 2 < len(lines) and self._is_date_line(lines[i + 2]) else ""
            edu.append({"school": school, "degree": degree, "date_range": date_range})
            i += 2 + (1 if date_range else 0)
            # Skip description if any
            while i < len(lines) and not self._looks_like_school(lines[i]):
                i += 1
        return edu

    def _parse_skills_text(self, text: str) -> list[str]:
        if not text:
            return []
        # Skills section text is typically comma-separated or newline-separated skill names
        skills = []
        for line in text.strip().split("\n"):
            # Each line might be "Skill Name\nEndorsements"
            skill = line.strip()
            if skill and len(skill) < 60:
                skills.append(skill)
        return skills

    def _parse_languages_text(self, text: str) -> list[dict]:
        if not text:
            return []
        langs = []
        for line in text.strip().split("\n"):
            parts = line.strip().split("\n")
            for p in parts:
                if p:
                    langs.append({"name": p.strip(), "proficiency": ""})
        return langs

    def _is_date_line(self, line: str) -> bool:
        line = line.strip()
        return bool(re.search(r'\b(19|20)\d{2}\b', line)) or "·" in line or " - " in line or " – " in line

    def _looks_like_company_start(self, line: str, next_lines: list[str]) -> bool:
        """Heuristic: a short line followed by a longer title line might be a new position."""
        if not line or len(line) > 50:
            return False
        if not next_lines:
            return False
        return not self._is_date_line(line) and line.strip() != ""

    def _looks_like_school(self, line: str) -> bool:
        """Heuristic: is this line the start of a new education entry?"""
        if not line:
            return False
        # School names often contain "University", "College", "Institute", etc.
        low = line.lower()
        return any(w in low for w in ["university", "college", "institute", "school", "polytechnic"])

    async def _expand_sections(self):
        """Scroll down and click 'Show more' buttons."""
        try:
            for _ in range(5):
                await self.page.evaluate("window.scrollBy(0, 800)")
                await self.page.wait_for_timeout(800)
        except Exception:
            return
        # Click "Show all N experiences" / "Show all N skills" etc.
        show_buttons = await self.page.query_selector_all(
            'a:has-text("Show all"), button:has-text("Show all"), '
            'div.inline-show-more-text >> visible=true'
        )
        for btn in show_buttons:
            try:
                await btn.click()
                await self.page.wait_for_timeout(600)
            except Exception:
                pass

    async def _extract_experience(self) -> list[dict]:
        selectors = [
            "#experience ~ div ul li.artdeco-list__item",
            "#experience ~ div .pvs-list__item",
            "section#experience .pvs-list__container li",
            "section.experience .profile-section-card",
        ]
        items = await self._query_all(selectors)
        return await self._parse_section_items(items, "title_company_date")

    async def _extract_education(self) -> list[dict]:
        selectors = [
            "#education ~ div ul li.artdeco-list__item",
            "#education ~ div .pvs-list__item",
            "section#education .pvs-list__container li",
        ]
        items = await self._query_all(selectors)
        return await self._parse_section_items(items, "school_degree_date")

    async def _extract_skills(self) -> list[str]:
        selectors = [
            "#skills ~ div ul li span[aria-hidden]",
            "section#skills .pvs-list__container li span[aria-hidden]",
            "section.skills .profile-section-card__skill",
        ]
        skills = []
        seen = set()
        items = await self._query_all(selectors)
        for item in items:
            text = (await item.inner_text()).strip()
            if text and text not in seen:
                skills.append(text)
                seen.add(text)
        return skills

    async def _extract_languages(self) -> list[dict]:
        selectors = [
            "#languages ~ div ul li.artdeco-list__item",
            "#languages ~ div .pvs-list__item",
            "section#languages .pvs-list__container li",
        ]
        items = await self._query_all(selectors)
        results = []
        for item in items:
            text = (await item.inner_text()).strip()
            lines = [l.strip() for l in text.split("\n") if l.strip()]
            if lines:
                lang = {"name": lines[0]}
                if len(lines) > 1:
                    lang["proficiency"] = lines[1]
                results.append(lang)
        return results

    async def _parse_section_items(self, items, mode: str) -> list[dict]:
        results = []
        for item in items:
            text = (await item.inner_text()).strip()
            lines = [l.strip() for l in text.split("\n") if l.strip()]
            if not lines:
                continue
            entry = {}
            if mode == "title_company_date":
                if len(lines) < 2:
                    continue
                entry["title"] = lines[0]
                entry["company"] = lines[1]
                entry["date_range"] = ""
                for line in lines:
                    if "·" in line:
                        parts = line.split("·")
                        entry["date_range"] = parts[0].strip()
                        break
                entry["description"] = ""
            elif mode == "school_degree_date":
                entry["school"] = lines[0] if len(lines) > 0 else ""
                entry["degree"] = lines[1] if len(lines) > 1 else ""
                entry["date_range"] = ""
                for line in lines:
                    if "·" in line or " - " in line or " – " in line:
                        entry["date_range"] = line.strip()
                        break
            results.append(entry)
        return results


def _normalize_scraped_data(raw: dict) -> dict:
    """Convert scraped data to the same format as CSV export data."""
    data = {
        "headline": raw.get("headline", ""),
        "summary": raw.get("summary", ""),
        "positions": [],
        "education": [],
        "skills": raw.get("skills", []),
        "languages": raw.get("languages", []),
    }

    for pos in raw.get("positions", []):
        start, end = _parse_scraped_date_range(pos.get("date_range", ""))
        data["positions"].append({
            "title": pos.get("title", ""),
            "company": pos.get("company", ""),
            "start": start,
            "end": end,
            "description": pos.get("description", ""),
            "location": "",
        })

    for edu in raw.get("education", []):
        start, end = _parse_scraped_date_range(edu.get("date_range", ""))
        data["education"].append({
            "school": edu.get("school", ""),
            "degree": edu.get("degree", ""),
            "start": start,
            "end": end,
            "notes": "",
        })

    return data


def _parse_scraped_date_range(dr: str) -> tuple[str, str]:
    """Parse scraped date range like 'Mar 2022 - Present · 3 yrs 4 mos'."""
    if not dr:
        return "", ""
    # Remove duration part
    dr = dr.split("·")[0].strip()
    # Try various separators
    for sep in (" - ", " – ", " — ", " to "):
        if sep in dr:
            start, end = dr.split(sep, 1)
            return _parse_date(start.strip()), _parse_date(end.strip())
    # Single date — assume it's both start and end
    return _parse_date(dr.strip()), _parse_date(dr.strip())


def scrape_linkedin_profile(profile_url: str, headless: bool = True, debug: bool = False) -> dict:
    """Synchronous wrapper around LinkedInScraper.scrape()."""
    import asyncio

    scraper = LinkedInScraper(profile_url, headless=headless)
    try:
        raw = asyncio.run(scraper.scrape(debug=debug))
        if not raw:
            print(
                "\nCould not connect to Chrome via CDP.\n"
                "Start Chrome with remote debugging first:\n"
                '  open -a "Google Chrome" --args --remote-debugging-port=9222\n'
                "Then re-run: python align_linkedin.py --scrape"
            )
            sys.exit(1)
        return _normalize_scraped_data(raw)
    except ImportError:
        print(
            "Playwright is required for scraping. Install with:\n"
            "  pip install playwright && playwright install chromium"
        )
        sys.exit(1)


# ---------------------------------------------------------------------------
# Comparator
# ---------------------------------------------------------------------------

def _clean_for_match(s: str) -> str:
    """Normalize text for comparison: strip LaTeX accents, normalize dashes, strip diacritics."""
    # Normalize unicode: decompose accented chars, strip combining marks (à -> a)
    s = unicodedata.normalize('NFKD', s)
    s = re.sub(r'[̀-ͯ]', '', s)
    # Replace LaTeX accent commands: \`a -> a, \'e -> e, \"o -> o, etc.
    s = re.sub(r'\\([`\'"^~=cHk])([a-zA-Z])', r'\2', s)
    # Strip remaining backslashes and braces
    s = s.replace('\\', '').replace('{', '').replace('}', '')
    # Normalize dashes (em-dash, en-dash, double-hyphen -> single hyphen)
    s = s.replace('--', '-').replace('–', '-').replace('—', '-')
    # Normalize ampersand LaTeX escapes
    s = s.replace('\\&', '&')
    # Expand common abbreviations
    s = re.sub(r'\br ?& ?d\b', 'research and development', s, flags=re.IGNORECASE)
    # Collapse whitespace
    s = re.sub(r'\s+', ' ', s).strip()
    return s


# Canonical names for schools/companies that are known aliases of each other
_COMPANY_CANONICAL = {
    'saarland university': 'universitat des saarlandes',
    'university of florence': 'universita degli studi di firenze',
}


def _fuzzy_match(a: str, b: str) -> bool:
    """Case-insensitive substring match after normalising."""
    a = re.sub(r'\s+', ' ', a.lower().strip())
    b = re.sub(r'\s+', ' ', b.lower().strip())
    a = _clean_for_match(a)
    b = _clean_for_match(b)
    return a in b or b in a

def _normalise_company(name: str) -> str:
    """Normalise company names for comparison."""
    name = name.lower().strip()
    name = _clean_for_match(name)
    # Strip common suffixes/variations
    for suffix in [', a ge company', ', a synopsys company', ' (a ge company)',
                   ', a ge co.', ' corporation', ' corp.', ' inc.', ' ltd.',
                   ' s.r.l.', ' s.p.a.', ' spa', ' srls', ' inc', ' ltd']:
        name = name.replace(suffix, '')
    # Remove any remaining punctuation at end
    name = name.strip().rstrip('., ')
    # Resolve through canonical aliases
    if name in _COMPANY_CANONICAL:
        name = _COMPANY_CANONICAL[name]
    return name

def compare(cv: CVProfile, linkedin_data: dict) -> list[str]:
    """Compare CV against LinkedIn data, return list of discrepancies."""
    issues = []

    # --- Headline ---
    li_headline = linkedin_data.get('headline', '')
    if cv.headline and not _fuzzy_match(cv.headline, li_headline):
        issues.append(f"[HEADLINE] CV: '{cv.headline}' vs LI: '{li_headline}'")

    # --- Summary ---
    li_summary = linkedin_data.get('summary', '')
    if cv.summary and not li_summary:
        issues.append("[SUMMARY] LinkedIn has no summary. CV summary exists.")

    # --- Positions ---
    li_positions = linkedin_data.get('positions', [])
    # Match by company + approximate date
    for cv_pos in cv.positions:
        matched = False
        cv_co = _normalise_company(cv_pos.company)
        for li_pos in li_positions:
            li_co = _normalise_company(li_pos.get('company', ''))
            if cv_co == li_co or cv_co in li_co or li_co in cv_co:
                # Check title (normalize dashes and LaTeX first)
                cv_title = _clean_for_match(cv_pos.title.lower().strip())
                li_title = _clean_for_match(li_pos.get('title', '').lower().strip())
                if cv_title in li_title or li_title in cv_title:
                    matched = True
                    # Check description
                    li_desc = li_pos.get('description', '')
                    if not li_desc and cv_pos.description:
                        issues.append(
                            f"[POSITION] '{cv_pos.title}' at '{cv_pos.company}' "
                            f"has no description on LinkedIn. CV has {len(cv_pos.description)} bullets."
                        )
                    break
        if not matched and cv_pos.company:
            issues.append(
                f"[POSITION] CV entry '{cv_pos.title}' at '{cv_pos.company}' "
                f"({cv_pos.start} – {cv_pos.end}) not found on LinkedIn"
            )

    # --- Skills ---
    li_skills = linkedin_data.get('skills', [])
    for skill in cv.skills:
        if not any(_fuzzy_match(skill, li_skill) for li_skill in li_skills):
            issues.append(f"[SKILL] '{skill}' missing from LinkedIn skills list")

    # --- Languages ---
    li_langs = [l.get('name', '').lower().strip() for l in linkedin_data.get('languages', [])]
    for lang in cv.languages:
        if lang.name.lower().strip() not in li_langs:
            issues.append(f"[LANGUAGE] '{lang.name}' missing from LinkedIn languages")

    # --- Education ---
    li_edu = linkedin_data.get('education', [])
    for cv_edu in cv.education:
        matched = False
        for li_ed in li_edu:
            if _fuzzy_match(cv_edu.school, li_ed.get('school', '')) and \
               _fuzzy_match(cv_edu.degree, li_ed.get('degree', '')):
                matched = True
                break
        if not matched:
            issues.append(
                f"[EDUCATION] '{cv_edu.degree}' at '{cv_edu.school}' not found on LinkedIn"
            )

    # --- Certifications ---
    for cert in cv.certifications:
        issues.append(
            f"[CERTIFICATION] '{cert.title} ({cert.issuer})' — "
            f"verify it is listed on LinkedIn"
        )

    # --- Courses ---
    for course in cv.courses:
        issues.append(
            f"[COURSE] '{course.title}' by '{course.provider}' ({course.date}) — "
            f"verify it is listed on LinkedIn"
        )

    # --- Publications ---
    li_pubs = linkedin_data.get('publications', [])
    if not li_pubs and cv.publications:
        issues.append(
            f"[PUBLICATIONS] {len(cv.publications)} publications in CV, "
            f"none found in LinkedIn export. Add them to the 'Publications' section."
        )

    # --- Awards ---
    li_awards = linkedin_data.get('awards', [])
    if not li_awards and cv.awards:
        issues.append(
            f"[AWARDS] {len(cv.awards)} awards in CV, none in LinkedIn export. "
            f"Add them to the 'Honors & Awards' section."
        )

    return issues


# ---------------------------------------------------------------------------
# Report generators
# ---------------------------------------------------------------------------

def print_summary(profile: CVProfile):
    """Print a structured summary of the CV data."""
    print(f"\n{'='*60}")
    print(f"  {profile.name}")
    print(f"  {profile.headline}")
    print(f"  {profile.email}  |  {profile.location}")
    print(f"  linkedin.com/in/{profile.linkedin}  |  github.com/{profile.github}")
    print(f"{'='*60}")

    if profile.summary:
        print(f"\n--- Summary ---")
        print(profile.summary)

    print(f"\n--- Experience ({len(profile.positions)} entries) ---")
    for p in profile.positions:
        print(f"  [{p.start} – {p.end}] {p.title} @ {p.company} ({p.location})")
        for b in p.description:
            print(f"      • {b}")

    print(f"\n--- Education ({len(profile.education)} entries) ---")
    for e in profile.education:
        print(f"  [{e.start} – {e.end}] {e.degree} @ {e.school} ({e.location})")

    print(f"\n--- Skills ({len(profile.skills)}) ---")
    print(f"  {', '.join(profile.skills)}")

    print(f"\n--- Languages ({len(profile.languages)}) ---")
    for l in profile.languages:
        bars = '█' * l.level + '░' * (5 - l.level)
        print(f"  {l.name:<12} {bars} ({l.level}/5)")

    print(f"\n--- Awards ({len(profile.awards)}) ---")
    for a in profile.awards:
        print(f"  [{a.date}] {a.title}")

    print(f"\n--- Certifications ({len(profile.certifications)}) ---")
    for c in profile.certifications:
        print(f"  {c.title} — {c.issuer}")

    print(f"\n--- Courses ({len(profile.courses)}) ---")
    for c in profile.courses:
        print(f"  [{c.date}] {c.title} @ {c.provider} ({c.location})")

    print(f"\n--- Publications ({len(profile.publications)}) ---")
    for p in profile.publications:
        print(f"  [{p.year}] [{p.pub_type}] {p.title}")
        print(f"      {p.venue}")

    print(f"\n--- Recommendations ({len(profile.recommendations)}) ---")
    for r in profile.recommendations:
        print(f"  {r.author}, {r.role} ({r.date})")
        print(f"      \"{r.text[:120]}...\"")


def print_comparison(issues: list[str]):
    """Print the comparison report."""
    if not issues:
        print("\n✓ LinkedIn profile is aligned with CV. No discrepancies found.")
        return

    print(f"\n{'='*60}")
    print(f"  LinkedIn Alignment Report — {len(issues)} action(s) needed")
    print(f"{'='*60}\n")

    for i, issue in enumerate(issues, 1):
        print(f"  {i}. {issue}")

    print(f"\n{'='*60}")
    print(f"  Summary: {len(issues)} item(s) to review on LinkedIn")
    print(f"{'='*60}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Align LinkedIn profile with CV data from my.tex / cv.tex"
    )
    parser.add_argument(
        '--base-dir', default=os.path.dirname(os.path.abspath(__file__)),
        help='Directory containing my.tex and cv.tex (default: script directory)'
    )
    parser.add_argument(
        '--linkedin-dir',
        help='Path to LinkedIn data export directory (from "Download Your Data")'
    )
    parser.add_argument(
        '--scrape', nargs='?', const='__from_profile__', metavar='URL',
        help='Scrape LinkedIn profile (uses profile URL from my.tex if omitted)'
    )
    parser.add_argument(
        '--no-headless', action='store_true',
        help='Show browser window during scraping (for debugging)'
    )
    parser.add_argument(
        '--json', action='store_true',
        help='Dump CV data as JSON'
    )
    parser.add_argument(
        '--debug', action='store_true',
        help='Save page screenshot and HTML for debugging selectors'
    )
    args = parser.parse_args()

    profile = build_profile(args.base_dir)

    if args.json:
        print(json.dumps(asdict(profile), indent=2, default=str, ensure_ascii=False))
        return

    if args.scrape:
        url = args.scrape
        if url == '__from_profile__':
            url = f"https://www.linkedin.com/in/{profile.linkedin}/"
            if profile.linkedin == '':
                print("Error: LinkedIn handle not found in my.tex. Provide URL explicitly.")
                sys.exit(1)
        print(f"Scraping {url} ...")
        linkedin_data = scrape_linkedin_profile(url, headless=not args.no_headless, debug=args.debug)
        if not linkedin_data:
            print("Scraping failed.")
            sys.exit(1)
        issues = compare(profile, linkedin_data)
        print_comparison(issues)
    elif args.linkedin_dir:
        linkedin_data = read_linkedin_export(args.linkedin_dir)
        issues = compare(profile, linkedin_data)
        print_comparison(issues)
    else:
        print_summary(profile)
        print(
            "\nTo compare against LinkedIn, either:"
            "\n  1. Scrape: python align_linkedin.py --scrape"
            "\n  2. Export: download your LinkedIn data archive"
            " (Settings > Data Privacy > Get a copy of your data),"
            " extract it, and re-run with:"
            "\n     python align_linkedin.py --linkedin-dir <path-to-extracted-csvs>"
        )


if __name__ == '__main__':
    main()
