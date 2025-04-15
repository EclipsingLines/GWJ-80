# Automated Documentation System

This document describes the automated documentation system for the Cline project, focusing on bug fixes and feature additions.

## Folder Structure

The following folder structure is used to store documentation files:

```
cline_docs/
├── bugs/
│   └── YYYYMMDD-HHMMSS-bug-[task_name].md
└── features/
    └── YYYYMMDD-HHMMSS-feature-[task_name].md
```

## Naming Convention

The following naming convention is used for archived documentation files:

`YYYYMMDD-HHMMSS-[bug|feature]-[task_name].md`

* `YYYYMMDD` - Year, month, and day
* `HHMMSS` - Hour, minute, and second
* `[bug|feature]` - Indicates whether the task was a bug fix or a feature addition
* `[task_name]` - The name of the task from `projectRoadmap.md`

Example: `20250323-083000-feature-add_automated_documentation.md`

## Archiving Process

After the completion of each task documented in `currentTask.md`, the LLM must automatically archive the contents of `currentTask.md` into either the `cline_docs/bugs` or `cline_docs/features` folder, depending on whether the completed task addressed a bug or implemented a new feature.

## Task Roadmap Integration

Within each archived documentation file, the LLM must automatically insert a direct link back to the corresponding task entry in the project's task roadmap. This link should facilitate quick and easy cross-referencing between the documentation and the overall project plan.

The link should be in the format:

`[Task Roadmap Link](projectRoadmap.md#task-name)`

Replace `task-name` with the actual task name from `projectRoadmap.md`.
