# Shared Resources for OpenShift Lessons

This directory contains shared resources to improve DRY (Don't Repeat Yourself) compliance across all OpenShift lesson README files.

## 📁 File Structure

```
shared/
├── README.md                    # This file - explains the shared resources
├── prerequisites.md             # Shared prerequisites for all lessons
├── common-commands.md           # Comprehensive OpenShift command reference
├── troubleshooting.md           # Shared troubleshooting guide
└── lesson-template.md           # Template for creating new lessons
```

## 🎯 Purpose

These shared resources eliminate duplication across lesson files by providing:

1. **Centralized Prerequisites**: All installation and setup instructions
2. **Command Reference**: Complete OpenShift CLI command reference
3. **Troubleshooting Guide**: Common issues and solutions
4. **Lesson Template**: Standardized structure for new lessons

## 📋 How to Use

### For Existing Lessons

When updating existing lesson README files, replace duplicated content with references:

#### Before (Duplicated Content):
```markdown
### Prerequisites
- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- Web browser for console access
```

#### After (DRY Compliant):
```markdown
### Prerequisites

> **📋 Reference**: See [shared/prerequisites.md](../shared/prerequisites.md) for detailed prerequisites and installation instructions.

- OpenShift cluster access (from previous days)
- OpenShift CLI (`oc`) installed and configured
- [Additional day-specific prerequisites]
```

### For New Lessons

Use the lesson template to create new lessons:

1. Copy `lesson-template.md` to your lesson directory
2. Rename it to `README.md`
3. Replace placeholder content with lesson-specific information
4. Reference shared resources where appropriate

## 🔧 Implementation Benefits

### Reduced Maintenance
- **Single Source of Truth**: Update commands in one place
- **Consistent Formatting**: Standardized structure across all lessons
- **Easier Updates**: Change prerequisites once, affects all lessons

### Improved User Experience
- **Comprehensive Reference**: Complete command reference available
- **Better Troubleshooting**: Centralized troubleshooting guide
- **Consistent Navigation**: Standardized lesson structure

### Quality Assurance
- **DRY Compliance**: Eliminates code duplication
- **Consistency**: Uniform formatting and structure
- **Maintainability**: Easier to update and maintain

## 📝 Migration Guide

### Step 1: Update Prerequisites Sections
Replace duplicated prerequisites with references to `shared/prerequisites.md`

### Step 2: Add Command References
Add references to `shared/common-commands.md` in appropriate sections

### Step 3: Update Troubleshooting
Replace duplicated troubleshooting with references to `shared/troubleshooting.md`

### Step 4: Standardize Structure
Ensure all lessons follow the template structure from `lesson-template.md`

## 🎨 Template Usage

### Creating a New Lesson
```bash
# Copy the template
cp shared/lesson-template.md day11/README.md

# Edit the new lesson
# Replace placeholders with actual content
# Add references to shared resources
```

### Updating Existing Lessons
1. Identify duplicated content
2. Replace with references to shared resources
3. Keep lesson-specific content
4. Test all links and references

## 📊 DRY Compliance Metrics

### Before Implementation
- ❌ Prerequisites duplicated in 10 files
- ❌ Common commands repeated across lessons
- ❌ Troubleshooting sections duplicated
- ❌ Inconsistent structure

### After Implementation
- ✅ Single prerequisites file
- ✅ Centralized command reference
- ✅ Shared troubleshooting guide
- ✅ Standardized lesson template
- ✅ Reduced maintenance overhead
- ✅ Improved consistency

## 🔗 Related Files

- `../README.md` - Main OpenShift learning series overview
- `../day01/README.md` through `../day10/README.md` - Individual lessons
- `../../README.md` - Project root documentation

## 📞 Support

For questions about using these shared resources or implementing DRY improvements:

1. Check the individual shared files for detailed information
2. Use the lesson template for new lessons
3. Follow the migration guide for updating existing lessons
4. Ensure all references are properly linked

---

**💡 Tip**: Always test references and links after making changes to ensure they work correctly across all lesson files. 