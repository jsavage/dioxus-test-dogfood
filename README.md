# Dioxus Test App - Dogfooding Repository

This repository demonstrates a "dogfooding" approach: There is a workflow file whos action is triggered whenever changed are committed to either the setup script or the workflow file.
The setup script generates a complete Dioxus project, which is automatically committed back to this repository and can be cloned to a server for testing or deployment.
Perfect for testing a webserver if you want to check the feasibility of deploying a dioxus project and are not sure how it works. 

## 🚀 Quick Start

### Use Generated Project (Fastest)

The `generated-project/` directory contains a ready-to-use Dioxus app:

\`\`\`bash
git clone https://github.com/yourusername/dioxus-test-dogfood.git
cd dioxus-test-dogfood/generated-project
dx serve  # Test locally
\`\`\`

### Run Setup Script Yourself

Generate a fresh project:

\`\`\`bash
./setup-dioxus-test.sh
\`\`\`

## 📋 How It Works

1. **Edit** `setup-dioxus-test.sh` (the only file you need to modify)
2. **Push** changes to GitHub
3. **GitHub Actions** runs the script automatically
4. **Generated project** is committed to `generated-project/`
5. **Everyone** gets the latest working project!

## 📦 Repository Structure

\`\`\`
dioxus-test-dogfood/
├── setup-dioxus-test.sh         # ← EDIT THIS (source of truth)
├── .github/workflows/
│   └── dogfood.yml              # ← Automates everything
├── README.md                    # ← This file
└── generated-project/           # ← AUTO-GENERATED (don't edit!)
    ├── Cargo.toml
    ├── Dioxus.toml
    ├── src/main.rs
    ├── dioxus-deploy.zip        # ← Ready to deploy!
    └── GENERATED_MANIFEST.md    # ← Generation details
\`\`\`

## 🎯 Deployment

### Option 1: From Repository

\`\`\`bash
cd generated-project
# Upload dioxus-deploy.zip to your shared hosting
# Extract in a folder named 'dioxus'
# Access at: https://yourdomain.com/dioxus/
\`\`\`

### Option 2: From GitHub Actions

1. Go to [Actions](../../actions) tab
2. Click latest successful workflow run
3. Download `dioxus-deployment-package` artifact
4. Upload and extract on your hosting

## 🧪 Testing

Every change to `setup-dioxus-test.sh` automatically triggers:

- ✅ Full script execution
- ✅ Project generation
- ✅ Build verification
- ✅ Independent build test
- ✅ Artifact creation

View test results in the [Actions](../../actions) tab.

## 📝 Making Changes

\`\`\`bash
# 1. Edit the setup script
vim setup-dioxus-test.sh

# 2. Commit and push
git add setup-dioxus-test.sh
git commit -m "Update: describe your changes"
git push

# 3. Wait for GitHub Actions to complete
# 4. Pull the auto-generated project
git pull
\`\`\`

## ✅ Golden Rules

| ✅ DO | ❌ DON'T |
|-------|----------|
| Edit `setup-dioxus-test.sh` | Edit files in `generated-project/` |
| Let workflow commit changes | Manually update `generated-project/` |
| Pull after workflow completes | Ignore workflow failures |

## 🔍 Viewing Results

### In Repository
\`\`\`bash
git pull
cd generated-project
cat GENERATED_MANIFEST.md  # See generation details
\`\`\`

### In GitHub
- **Actions Tab**: Step-by-step workflow logs
- **Artifacts**: Downloadable build packages
- **Summary**: Each run shows generation results

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| No `generated-project/` | Wait for workflow to complete, then `git pull` |
| Workflow fails | Check Actions tab for error logs |
| Files not updating | Script output may be identical to previous run |

## 📚 Documentation

- Full setup guide: See comments in `setup-dioxus-test.sh`
- Workflow details: See `.github/workflows/dogfood.yml`
- Generation details: See `generated-project/GENERATED_MANIFEST.md`

## 🎓 Learn More

- [Dioxus Documentation](https://dioxuslabs.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📄 License

MIT
\`\`\`

---

## File 3: `.gitignore`

**Location:** `.gitignore` (root of repository)

\`\`\`
# Local test runs of the script
/dioxus-test/

# Don't ignore generated-project/ - we want to commit it!
# The .gitignore inside generated-project/ will handle that folder

# macOS
.DS_Store

# Editor files
*.swp
*~
.vscode/
.idea/
\`\`\`

---

## Quick Setup Commands

Run these commands to set up your repository:

\`\`\`bash
# 1. Create repository directory
mkdir dioxus-test-dogfood
cd dioxus-test-dogfood

# 2. Initialize git
git init

# 3. Create directory structure
mkdir -p .github/workflows

# 4. Copy setup-dioxus-test.sh here (your existing script)

# 5. Create .github/workflows/dogfood.yml (copy from File 1 above)

# 6. Create README.md (copy from File 2 above)

# 7. Create .gitignore (copy from File 3 above)

# 8. Make script executable
chmod +x setup-dioxus-test.sh

# 9. Initial commit
git add .
git commit -m "Initial commit: Dogfooding setup"

# 10. Create GitHub repository and push
git remote add origin https://github.com/yourusername/dioxus-test-dogfood.git
git branch -M main
git push -u origin main

# 11. Wait for workflow to complete, then pull
git pull
\`\`\`

---

## Summary

You need to create **3 files**:

1. `.github/workflows/dogfood.yml` - The GitHub Actions workflow
2. `README.md` - Repository documentation
3. `.gitignore` - Git ignore rules

Plus your existing `setup-dioxus-test.sh` script.

After pushing, GitHub Actions will automatically run the script and commit the generated project to `generated-project/`.
