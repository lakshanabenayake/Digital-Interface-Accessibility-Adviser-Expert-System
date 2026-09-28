from __future__ import annotations

import html
import re
import textwrap
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    KeepTogether,
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "REPORT.md"
OUTPUT = ROOT / "output" / "pdf" / "Digital_Interface_Accessibility_Adviser_Report.pdf"


styles = getSampleStyleSheet()
styles.add(ParagraphStyle(
    name="CoverTitle", parent=styles["Title"], fontName="Helvetica-Bold",
    fontSize=22, leading=27, alignment=TA_CENTER, spaceAfter=12,
    textColor=colors.HexColor("#1F3A5F"),
))
styles.add(ParagraphStyle(
    name="CoverSubtitle", parent=styles["Normal"], fontName="Helvetica",
    fontSize=14, leading=18, alignment=TA_CENTER, spaceAfter=28,
))
styles.add(ParagraphStyle(
    name="ReportH1", parent=styles["Heading1"], fontName="Helvetica-Bold",
    fontSize=16, leading=20, spaceBefore=10, spaceAfter=8,
    textColor=colors.HexColor("#1F3A5F"), keepWithNext=True,
))
styles.add(ParagraphStyle(
    name="ReportH2", parent=styles["Heading2"], fontName="Helvetica-Bold",
    fontSize=12.5, leading=16, spaceBefore=9, spaceAfter=5,
    textColor=colors.HexColor("#263F5F"), keepWithNext=True,
))
styles.add(ParagraphStyle(
    name="ReportH3", parent=styles["Heading3"], fontName="Helvetica-Bold",
    fontSize=10.5, leading=14, spaceBefore=7, spaceAfter=4,
    textColor=colors.HexColor("#263F5F"), keepWithNext=True,
))
styles.add(ParagraphStyle(
    name="ReportBody", parent=styles["BodyText"], fontName="Helvetica",
    fontSize=9.3, leading=13.2, alignment=TA_LEFT, spaceAfter=6,
))
styles.add(ParagraphStyle(
    name="ReportBullet", parent=styles["ReportBody"], leftIndent=14,
    firstLineIndent=-8, bulletIndent=5, spaceAfter=3,
))
styles.add(ParagraphStyle(
    name="ReportQuote", parent=styles["ReportBody"], leftIndent=14,
    rightIndent=8, borderColor=colors.HexColor("#AAB7C4"), borderWidth=0,
    borderPadding=5, backColor=colors.HexColor("#F5F7F9"),
))
styles.add(ParagraphStyle(
    name="ReportCode", parent=styles["Code"], fontName="Courier", fontSize=7.7,
    leading=10, leftIndent=8, rightIndent=8, spaceBefore=3, spaceAfter=7,
    backColor=colors.HexColor("#F4F5F6"), borderPadding=7,
))
styles.add(ParagraphStyle(
    name="TableHead", parent=styles["ReportBody"], fontName="Helvetica-Bold",
    fontSize=7.3, leading=9.2, textColor=colors.white, spaceAfter=0,
))
styles.add(ParagraphStyle(
    name="TableCell", parent=styles["ReportBody"], fontSize=7.2,
    leading=9.2, spaceAfter=0,
))


def inline_markup(text: str) -> str:
    placeholders: list[tuple[str, str]] = []

    def hold(value: str) -> str:
        token = f"@@TOKEN{len(placeholders)}@@"
        placeholders.append((token, value))
        return token

    text = re.sub(
        r"\[([^\]]+)\]\((https?://[^)]+)\)",
        lambda m: hold(f'<link href="{html.escape(m.group(2), quote=True)}" color="#174F7A"><u>{html.escape(m.group(1))}</u></link>'),
        text,
    )
    text = re.sub(
        r"`([^`]+)`",
        lambda m: hold(f'<font name="Courier">{html.escape(m.group(1))}</font>'),
        text,
    )
    text = html.escape(text, quote=False)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<i>\1</i>", text)
    for token, value in placeholders:
        text = text.replace(token, value)
    return text


def wrap_code(lines: list[str], width: int = 86) -> str:
    """Wrap long source lines so code samples stay inside the page margins."""
    wrapped: list[str] = []
    for line in lines:
        if not line:
            wrapped.append("")
            continue
        parts = textwrap.wrap(
            line,
            width=width,
            subsequent_indent="  ",
            break_long_words=False,
            break_on_hyphens=False,
        )
        wrapped.extend(parts or [""])
    return "\n".join(wrapped)


def column_widths(count: int, available: float) -> list[float]:
    ratios = {
        2: [0.31, 0.69],
        3: [0.18, 0.18, 0.64],
        4: [0.10, 0.30, 0.27, 0.33],
        5: [0.07, 0.27, 0.22, 0.20, 0.24],
    }.get(count, [1 / count] * count)
    return [available * ratio for ratio in ratios]


def parse_table(lines: list[str], available: float) -> Table:
    rows: list[list[str]] = []
    for line in lines:
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if all(re.fullmatch(r":?-{3,}:?", cell or "") for cell in cells):
            continue
        rows.append(cells)
    count = max(len(row) for row in rows)
    normalized = [row + [""] * (count - len(row)) for row in rows]
    content = []
    for row_index, row in enumerate(normalized):
        style = styles["TableHead"] if row_index == 0 else styles["TableCell"]
        content.append([Paragraph(inline_markup(cell), style) for cell in row])
    table = Table(content, colWidths=column_widths(count, available), repeatRows=1, hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#40566F")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#AAB7C4")),
        ("BACKGROUND", (0, 1), (-1, -1), colors.white),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F6F8FA")]),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    return table


def build_story(text: str, available: float) -> list:
    lines = text.splitlines()
    story: list = []

    story.extend([
        Spacer(1, 28 * mm),
        Paragraph("Digital Interface Accessibility Adviser", styles["CoverTitle"]),
        Paragraph("Expert System Assignment Report", styles["CoverSubtitle"]),
        Spacer(1, 18 * mm),
        Table([
            ["Full name", "Abenayake D.M.R.L."],
            ["Student ID", "224002L"],
        ], colWidths=[42 * mm, 82 * mm], style=TableStyle([
            ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
            ("FONTNAME", (1, 0), (1, -1), "Helvetica"),
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("LINEBELOW", (1, 0), (1, -1), 0.4, colors.HexColor("#8B98A5")),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 9),
            ("TOPPADDING", (0, 0), (-1, -1), 9),
        ])),
        Spacer(1, 28 * mm),
        Paragraph("A rule-based adviser for preliminary accessibility assessment of web, desktop, and mobile software interfaces.", styles["CoverSubtitle"]),
        PageBreak(),
    ])

    start = next(i for i, line in enumerate(lines) if line.strip() == "## Abstract")
    i = start
    paragraph_parts: list[str] = []

    def flush_paragraph() -> None:
        if paragraph_parts:
            story.append(Paragraph(inline_markup(" ".join(paragraph_parts)), styles["ReportBody"]))
            paragraph_parts.clear()

    while i < len(lines):
        raw = lines[i]
        line = raw.strip()
        if not line:
            flush_paragraph()
            i += 1
            continue
        if line.startswith("```"):
            flush_paragraph()
            language = line[3:].strip()
            code: list[str] = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code.append(lines[i])
                i += 1
            story.append(Preformatted(wrap_code(code), styles["ReportCode"])); i += 1
            continue
        if line.startswith("|"):
            flush_paragraph()
            table_lines: list[str] = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                table_lines.append(lines[i].strip()); i += 1
            story.extend([parse_table(table_lines, available), Spacer(1, 6)])
            continue
        if line.startswith("### "):
            flush_paragraph(); story.append(Paragraph(inline_markup(line[4:]), styles["ReportH2"])); i += 1; continue
        if line.startswith("## "):
            flush_paragraph(); story.append(Paragraph(inline_markup(line[3:]), styles["ReportH1"])); i += 1; continue
        if line.startswith("> "):
            flush_paragraph(); story.append(Paragraph(inline_markup(line[2:]), styles["ReportQuote"])); i += 1; continue
        bullet_match = re.match(r"^-\s+(.+)$", line)
        number_match = re.match(r"^(\d+)\.\s+(.+)$", line)
        if bullet_match:
            flush_paragraph(); story.append(Paragraph("- " + inline_markup(bullet_match.group(1)), styles["ReportBullet"])); i += 1; continue
        if number_match:
            flush_paragraph(); story.append(Paragraph(number_match.group(1) + ". " + inline_markup(number_match.group(2)), styles["ReportBullet"])); i += 1; continue
        paragraph_parts.append(line)
        i += 1
    flush_paragraph()
    return story


def footer(canvas, document) -> None:
    canvas.saveState()
    width, _ = A4
    canvas.setStrokeColor(colors.HexColor("#D0D7DE"))
    canvas.setLineWidth(0.4)
    canvas.line(18 * mm, 14 * mm, width - 18 * mm, 14 * mm)
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#5B6570"))
    canvas.drawString(18 * mm, 9 * mm, "Digital Interface Accessibility Adviser")
    canvas.drawRightString(width - 18 * mm, 9 * mm, f"Page {document.page}")
    canvas.restoreState()


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    page_width, _ = A4
    left = right = 18 * mm
    document = SimpleDocTemplate(
        str(OUTPUT), pagesize=A4,
        leftMargin=left, rightMargin=right,
        topMargin=18 * mm, bottomMargin=19 * mm,
        title="Digital Interface Accessibility Adviser - Expert System Assignment Report",
        author="Abenayake D.M.R.L.",
        subject="Expert System Assignment",
    )
    story = build_story(SOURCE.read_text(encoding="utf-8"), page_width - left - right)
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    print(OUTPUT)


if __name__ == "__main__":
    main()
