# Shared Resources for OpenShift Lessons

Essential shared resources for OpenShift learning series.

## 📁 File Structure

```
shared/
├── README.md                    # This file
├── prerequisites.md             # Installation and setup
├── common-commands.md           # Essential OpenShift commands
├── troubleshooting.md           # Common issues and solutions
└── lesson-template.md           # Lesson structure template
```

## 🎯 Purpose

Centralized resources to avoid duplication across lessons:

1. **Prerequisites**: Installation and setup instructions
2. **Commands**: Essential OpenShift CLI commands
3. **Troubleshooting**: Common issues and solutions
4. **Template**: Standard lesson structure

## 📋 Usage

### In Lessons
Replace duplicated content with references:

```markdown
### Prerequisites
> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md)

### Commands
> **📋 Reference**: See [shared/common-commands.md](../shared/common-commands.md)

### Troubleshooting
> **📋 Reference**: See [shared/troubleshooting.md](../shared/troubleshooting.md)
```

### Creating New Lessons
1. Copy `lesson-template.md` to your lesson directory
2. Rename to `README.md`
3. Replace placeholders with lesson content
4. Reference shared resources where needed

---

**💡 Tip**: Always test references and links after making changes. 