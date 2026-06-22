# Style Guide for Markdown, R, Python, and UNIX-like Projects

This guide defines basic conventions for readable and reproducible analysis
projects.

The main rule is simple: prefer boring clarity over clever shortcuts. Code
should still be understandable months later, even without the original
context.

## 1. General rules

Use English for all comments, filenames, variable names, commit messages, and
documentation.

Use a text width of 78 characters. This keeps files readable in terminals,
side-by-side editor splits, Git diffs, and email-like plain-text contexts.

For Python, this is close to the traditional PEP 8 recommendation of 79
characters for code and 72 characters for comments and docstrings. The
project-local rule is therefore: prefer consistency across files and wrap at
78 characters.

Use lowercase names wherever possible. Avoid spaces, umlauts, special
characters, and inconsistent capitalization.

Prefer:

```text
01-load-data.R
02-clean-data.R
03-fit-blim.R
```

Avoid:

```text
Load Data.R
02_CleanData.R
03-fit-BLIM-final-new.R
```

## 2. Filenames

Numbered scripts should follow this pattern:

```text
<number>-<verb>-<subject>.<extension>
```

Use two-digit numbers to define execution order:

```text
01-load-data.R
02-clean-data.R
03-prepare-items.R
04-fit-blim.R
05-compare-models.R
06-create-plots.R
```

Use short, active verbs:

```text
load
clean
prepare
fit
compare
validate
plot
export
simulate
summarize
```

Avoid vague names:

```text
analysis.R
statistics.R
new-analysis.R
final.R
stuff.R
test2.R
```

Each script should have one main responsibility. The filename should answer the question: what does this script do?

## 3. Project structure

Use a similar structure across analysis projects:

```text
project-name/
├── README.md
├── .gitignore
├── scripts/
│   ├── 01-load-data.R
│   ├── 02-clean-data.R
│   ├── 03-fit-models.R
│   └── 04-create-plots.R
├── R/
│   └── helper-functions.R
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── output/
│   ├── tables/
│   ├── models/
│   └── logs/
├── figures/
└── notes/
```

Use the folders as follows:

```text
scripts/          numbered scripts run directly and in order
R/                helper functions sourced by scripts
data/raw/         original data; never edit by hand
data/processed/   cleaned data created by scripts
data/external/    codebooks, metadata, reference files
output/tables/    generated tables
output/models/    fitted models and .rds objects
output/logs/      logs and diagnostic output
figures/          exported plots and graphics
notes/            project notes and decisions
```

For very small projects, omit unused folders until they are needed.

Raw data should usually be read-only and excluded from Git when it is large, private, copyrighted, or not yours to redistribute. Processed data should be reproducible from scripts.

Example `.gitignore` entries:

```gitignore
.Rhistory
.RData
.Rproj.user/
__pycache__/
.ipynb_checkpoints/
data/raw/
data/local/
pisa-data/
output/cache/
```

## 4. Markdown files

Use lowercase Markdown filenames with hyphens:

```text
project-notes.md
model-comparison.md
style-guide.md
```

Avoid:

```text
Project Notes.md
ModelComparison.md
style_guide.md
```

Use one top-level heading per file:

```markdown
# Project Notes
```

Use sentence case for headings:

```markdown
## Load the data
## Fit the model
## Compare results
```

Avoid inconsistent heading styles:

```markdown
## Load The Data
## FIT MODEL
## compare_results
```

## 5. R and Python script structure

Each script should start with a short header:

```r
# 01-load-data.R
# author: hannes
# last edited: 2026-06-22

################################################################################
```

Use numbered sections:

```r
## 1. load packages

## 2. define paths

## 3. load data

## 4. process data

## 5. export data
```

Separate major sections with a 78-character `#` line:

```r
################################################################################
```

Use subsections when needed:

```r
## 3. load data

# 3.1 load raw response data

# 3.2 load item metadata
```

Section comments should structure the script. They should not repeat every line of code.

Prefer:

```r
## 2. define paths

raw_data_path <- "data/raw/pisa.csv"
processed_data_path <- "data/processed/pisa-clean.csv"
```

Avoid:

```r
# assign raw_data_path
raw_data_path <- "data/raw/pisa.csv"

# assign processed_data_path
processed_data_path <- "data/processed/pisa-clean.csv"
```

Do not use `setwd()` inside scripts.

Avoid:

```r
setwd("/home/hannes/project")
```

Prefer relative paths from the project root:

```r
data_path <- "data/raw/pisa.csv"
```

For larger Python scripts, use functions and a `main()` block:

```python
def load_data(path):
    return pd.read_csv(path)


def main():
    data = load_data("data/raw/pisa.csv")
    data.to_csv("data/processed/pisa-clean.csv", index=False)


if __name__ == "__main__":
    main()
```

## 6. Comments

Write comments in English. Avoid umlauts and special characters.

Comments should usually be lowercase unless capitalization improves readability, for example for acronyms or proper names.

Good comments explain purpose, assumptions, decisions, or warnings.

Prefer:

```r
# Remove incomplete response patterns because BLIM requires complete item vectors.
complete_data <- na.omit(response_data)
```

Avoid:

```r
# remove NAs
complete_data <- na.omit(response_data)
```

Good comments:

```r
# Keep only math items because the model is fitted to one domain.
# This threshold is intentionally conservative.
# The raw file is too large for Git and must be stored locally.
```

Avoid noisy comments:

```r
# create x
# run function
# save file
```

## 7. Object and variable names

Use lowercase names with underscores for variables and objects:

```r
raw_data
item_metadata
model_fit
response_matrix
student_responses
math_items
blim_fit
```

Avoid:

```r
RawData
itemMetadata
model.fit
responseMatrix
data2
result_new
final_object
```

Names should describe the content of the object. Short names such as `x`, `i`, or `j` are acceptable only for small local contexts.

## 8. Paths

Use relative paths from the project root:

```r
"data/raw/pisa.csv"
"data/processed/pisa-clean.csv"
"figures/model-comparison.png"
```

Avoid absolute local paths:

```r
"/home/hannes/gh/project/data/raw/pisa.csv"
"C:/Users/Hannes/Desktop/project/data.csv"
```

Use forward slashes in paths, also on Windows:

```text
data/raw/file.csv
```

## 9. Formatting

Use consistent spacing.

In R, use spaces around operators:

```r
x <- 1 + 2
mean_value <- mean(values)
```

Avoid:

```r
x<-1+2
mean_value<-mean(values)
```

In Python, use standard PEP 8-style spacing:

```python
mean_value = values.mean()
```

Avoid:

```python
mean_value=values.mean()
```

Keep lines reasonably short. Split lines when they become hard to read.

## 10. Git and reproducibility

Every project should have a `.gitignore`.

Do not commit large raw data, private data, cache folders, temporary files, or generated files that can be recreated.

Commit messages should be short, specific, and written in English.

Prefer:

```text
Add data loading script
Fit BLIM model
Compare BLIM and SLM results
Checkpoint before linear workflow restructuring
```

Avoid:

```text
changes
update
final
stuff
```

## 11. Minimal templates

R script template:

```r
# 01-load-data.R
# author: hannes
# last edited: 2026-06-22

################################################################################

## 1. load packages

################################################################################

## 2. define paths

################################################################################

## 3. load data

################################################################################

## 4. process data

################################################################################

## 5. export data
```

Python script template:

```python
# 01-load-data.py
# author: hannes
# last edited: 2026-06-22

################################################################################

## 1. import packages

################################################################################

## 2. define paths

################################################################################

## 3. load data

################################################################################

## 4. process data

################################################################################

## 5. export data
```

## 12. Summary

A good project is readable before it is clever.

Use English, lowercase names, hyphen-separated filenames, relative paths, numbered scripts, and reproducible project structure.

The default script naming pattern is:

```text
<number>-<verb>-<subject>.<extension>
```

Example:

```text
01-load-data.R
```

