#!/bin/bash
# Complete setup script for minimal Dioxus test app
# Creates a working Dioxus WASM app ready for deployment to shared hosting
# Lessons learned from actual deployment to HelioHost

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="dioxus-test"
BASE_PATH="/dioxus"  # The subdirectory on your web host

print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ========== CHECK PREREQUISITES ==========

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check for Rust/Cargo
    if ! command -v cargo &> /dev/null; then
        print_error "Cargo not found!"
        echo "Install Rust from: https://rustup.rs/"
        echo "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        exit 1
    fi
    print_success "Cargo found: $(cargo --version)"
    
    # Check for wasm32 target
    if ! rustup target list --installed | grep -q "wasm32-unknown-unknown"; then
        print_warning "WASM target not installed. Installing now..."
        rustup target add wasm32-unknown-unknown
    fi
    print_success "WASM target installed"
    
    # Check for Dioxus CLI
    if ! command -v dx &> /dev/null; then
        print_warning "Dioxus CLI not found. Installing now (this may take a few minutes)..."
        cargo install dioxus-cli
    fi
    DX_VERSION=$(dx --version 2>&1 | head -1)
    print_success "Dioxus CLI found: $DX_VERSION"
    
    # Check for zip (optional but recommended)
    if ! command -v zip &> /dev/null; then
        print_warning "zip not found. Install it for easier deployment."
        echo "  Ubuntu/Debian: sudo apt-get install zip"
        echo "  macOS: (already installed)"
    else
        print_success "zip found"
    fi
}

# ========== CREATE PROJECT ==========

create_project() {
    print_header "Creating Project Structure"
    
    if [ -d "$PROJECT_NAME" ]; then
        print_error "Directory '$PROJECT_NAME' already exists!"
        read -p "Delete and recreate? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_NAME"
            print_info "Deleted existing directory"
        else
            print_error "Aborted"
            exit 1
        fi
    fi
    
    mkdir -p "$PROJECT_NAME/src"
    cd "$PROJECT_NAME"
    print_success "Created project directory: $PROJECT_NAME"
}

# ========== CREATE CARGO.TOML ==========

create_cargo_toml() {
    print_info "Creating Cargo.toml..."
    
    cat > Cargo.toml << 'EOF'
[package]
name = "dioxus-test"
version = "0.1.0"
edition = "2021"

[dependencies]
dioxus = { version = "0.7", features = ["web"] }
wasm-bindgen = "=0.2.97"

[profile.release]
opt-level = "z"     # Optimize for size
lto = true          # Enable link-time optimization
codegen-units = 1   # Better optimization
panic = "abort"     # Smaller binary size
strip = true        # Remove debug symbols
EOF
    
    print_success "Created Cargo.toml (Dioxus 0.7)"
}

# ========== CREATE DIOXUS.TOML ==========

create_dioxus_toml() {
    print_info "Creating Dioxus.toml..."
    
    # CRITICAL: Use the base_path that matches your deployment folder name
    cat > Dioxus.toml << EOF
[application]
name = "dioxus-test"
default_platform = "web"

[web.app]
title = "Dioxus Test App"
base_path = "$BASE_PATH"

[web.watcher]

[web.resource.dev]

[web.resource.release]
EOF
    
    print_success "Created Dioxus.toml (base_path = $BASE_PATH)"
    print_warning "IMPORTANT: base_path must match your deployment folder name!"
}

# ========== CREATE MAIN.RS ==========

create_main_rs() {
    print_info "Creating src/main.rs..."
    
    cat > src/main.rs << 'EOF'
// Minimal Dioxus app to test deployment to shared hosting
use dioxus::prelude::*;

fn main() {
    launch(App);
}

#[component]
fn App() -> Element {
    let mut count = use_signal(|| 0);
    let mut message = use_signal(|| String::from(""));

    rsx! {
        div {
            style: "font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px;",
            
            h1 { "🎉 Dioxus Test App" }
            
            p {
                style: "font-size: 18px; color: #666;",
                "This is a minimal Dioxus app to test deployment to shared hosting."
            }
            
            div {
                style: "background: #f0f0f0; padding: 20px; border-radius: 8px; margin: 20px 0;",
                
                h2 { "Counter Test" }
                
                p {
                    style: "font-size: 24px; font-weight: bold; color: #2563eb;",
                    "Count: {count}"
                }
                
                div {
                    style: "display: flex; gap: 10px;",
                    
                    button {
                        style: "padding: 10px 20px; font-size: 16px; background: #2563eb; color: white; border: none; border-radius: 4px; cursor: pointer;",
                        onclick: move |_| count += 1,
                        "Increment"
                    }
                    
                    button {
                        style: "padding: 10px 20px; font-size: 16px; background: #dc2626; color: white; border: none; border-radius: 4px; cursor: pointer;",
                        onclick: move |_| count -= 1,
                        "Decrement"
                    }
                    
                    button {
                        style: "padding: 10px 20px; font-size: 16px; background: #6b7280; color: white; border: none; border-radius: 4px; cursor: pointer;",
                        onclick: move |_| count.set(0),
                        "Reset"
                    }
                }
            }
            
            div {
                style: "background: #f0f0f0; padding: 20px; border-radius: 8px; margin: 20px 0;",
                
                h2 { "Input Test" }
                
                input {
                    style: "width: 100%; padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 4px; margin: 10px 0;",
                    r#type: "text",
                    placeholder: "Type something...",
                    oninput: move |evt| message.set(evt.value().clone()),
                }
                
                if !message().is_empty() {
                    p {
                        style: "font-size: 18px; color: #059669; margin-top: 10px;",
                        "You typed: \"{message}\""
                    }
                }
            }
            
            div {
                style: "background: #dcfce7; padding: 20px; border-radius: 8px; margin: 20px 0;",
                
                h2 { "✅ Success!" }
                
                p { "If you can see this page and interact with the controls above, then:" }
                
                ul {
                    style: "line-height: 1.8;",
                    li { "✓ Dioxus compiled to WASM successfully" }
                    li { "✓ WASM is loading in your browser" }
                    li { "✓ Your shared hosting setup works!" }
                }
            }
            
            footer {
                style: "margin-top: 40px; padding-top: 20px; border-top: 1px solid #ccc; color: #666; font-size: 14px;",
                p { "Deployed as static WASM - no server-side code running" }
                p { 
                    "Built with "
                    a {
                        href: "https://dioxuslabs.com",
                        style: "color: #2563eb;",
                        "Dioxus"
                    }
                }
            }
        }
    }
}
EOF
    
    print_success "Created src/main.rs"
}

# ========== CREATE README ==========

create_readme() {
    print_info "Creating README.md..."
    
    cat > README.md << 'EOF'
# Dioxus Test App

A minimal Dioxus WASM application for testing deployment to shared hosting.

## What This Tests

- ✅ Dioxus compiles to WebAssembly
- ✅ WASM runs in browser (client-side only)
- ✅ No server-side code required
- ✅ Works on shared hosting (HelioHost, Plesk, etc.)

## Prerequisites

- Rust toolchain: https://rustup.rs/
- WASM target: `rustup target add wasm32-unknown-unknown`
- Dioxus CLI: `cargo install dioxus-cli`

## Build Locally

```bash
# Development server (with hot reload)
dx serve

# Production build
dx build --release --platform web
```

## Deploy to Shared Hosting

### Build Output Location

After running `dx build --release --platform web`, files are in:
```
target/dx/dioxus-test/release/web/public/
```

### Deployment Steps

1. **Create deployment package:**
   ```bash
   cd target/dx/dioxus-test/release/web/public/
   zip -r ~/dioxus-deploy.zip .
   ```

2. **Upload to your host:**
   - Log into Plesk/cPanel/File Manager
   - Navigate to `public_html` or `httpdocs`
   - Create folder named `dioxus` (must match base_path in Dioxus.toml)
   - Upload and extract `dioxus-deploy.zip` inside that folder

3. **Verify structure:**
   ```
   public_html/
     dioxus/           <- Folder name must match base_path
       index.html      <- Directly here (not in a subfolder!)
       assets/
         *.js
         *.wasm
   ```

4. **Access your app:**
   ```
   https://yourdomain.com/dioxus/
   ```

## Important Configuration

### base_path Must Match Deployment Folder

In `Dioxus.toml`:
```toml
[web.app]
base_path = "/dioxus"  # Must match your folder name!
```

If deploying to `/public_html/my-app/`, use:
```toml
base_path = "/my-app"
```

### Common Issues

**Blank page:**
- Check browser console (F12) for errors
- Verify base_path matches deployment folder name
- Ensure files are in correct location (not nested in extra folders)
- Check that .wasm and .js files uploaded completely

**404 errors for assets:**
- Wrong base_path in Dioxus.toml
- Files in wrong directory structure
- Need to rebuild after changing base_path

**MIME type warnings:**
Add to `.htaccess` in your deployment folder:
```apache
AddType application/wasm .wasm
AddType application/javascript .js
```

## File Sizes

Typical build output:
- WASM file: ~300-400 KB
- JS file: ~60 KB
- Total: ~450 KB (much smaller after gzip)

## Testing Locally

```bash
# After building, test the production files locally:
cd target/dx/dioxus-test/release/web/public/
python3 -m http.server 8000
# Visit: http://localhost:8000
```

## Success Criteria

If deployed correctly, you should be able to:
- ✓ See the page load
- ✓ Click counter buttons (increment/decrement/reset)
- ✓ Type in input field and see text echoed
- ✓ No errors in browser console

## Resources

- [Dioxus Documentation](https://dioxuslabs.com/)
- [Dioxus Web Platform Guide](https://dioxuslabs.com/learn/0.6/reference/web)
EOF
    
    print_success "Created README.md"
}

# ========== CREATE .GITIGNORE ==========

create_gitignore() {
    print_info "Creating .gitignore..."
    
    cat > .gitignore << 'EOF'
/target
Cargo.lock
.DS_Store
*.swp
*~
EOF
    
    print_success "Created .gitignore"
}

# ========== CREATE DEPLOYMENT HELPER SCRIPT ==========

create_deploy_script() {
    print_info "Creating deploy.sh helper script..."
    
    cat > deploy.sh << 'DEPLOY_EOF'
#!/bin/bash
# Deployment helper script
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Building for production...${NC}"
dx build --release --platform web

BUILD_DIR="target/dx/dioxus-test/release/web/public"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found!"
    exit 1
fi

echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo "Build output location:"
echo "  $BUILD_DIR"
echo ""
echo "Files ready for deployment:"
cd "$BUILD_DIR"
ls -lh
echo ""
echo "To create deployment package:"
echo "  cd $BUILD_DIR"
echo "  zip -r ~/dioxus-deploy.zip ."
echo ""
echo "Then upload to your host in a folder named 'dioxus'"
DEPLOY_EOF
    
    chmod +x deploy.sh
    print_success "Created deploy.sh (executable)"
}

# ========== BUILD PROJECT ==========

build_project() {
    print_header "Building Project"
    
    print_info "Running initial cargo check..."
    cargo check
    
    print_info "Building for release (this will take a few minutes on first build)..."
    dx build --release --platform web
    
    BUILD_DIR="target/dx/dioxus-test/release/web/public"
    
    if [ ! -d "$BUILD_DIR" ]; then
        print_error "Build failed - output directory not found!"
        exit 1
    fi
    
    print_success "Build complete!"
    
    echo ""
    print_info "Build output:"
    ls -lh "$BUILD_DIR"
    echo ""
    ls -lh "$BUILD_DIR/assets/"
}

# ========== CREATE DEPLOYMENT PACKAGE ==========

create_deployment_package() {
    print_header "Creating Deployment Package"
    
    BUILD_DIR="target/dx/dioxus-test/release/web/public"
    DEPLOY_ZIP="../dioxus-deploy.zip"
    
    if command -v zip &> /dev/null; then
        cd "$BUILD_DIR"
        
        if [ -f "$DEPLOY_ZIP" ]; then
            rm "$DEPLOY_ZIP"
        fi
        
        zip -r "$DEPLOY_ZIP" .
        cd - > /dev/null
        
        ZIP_SIZE=$(ls -lh "$DEPLOY_ZIP" | awk '{print $5}')
        print_success "Created deployment package: dioxus-deploy.zip ($ZIP_SIZE)"
    else
        print_warning "zip command not found. Skipping package creation."
        print_info "You can manually copy files from: $BUILD_DIR"
    fi
}

# ========== MAIN EXECUTION ==========

main() {
    print_header "Dioxus Test App Setup Script"
    
    echo "This script will:"
    echo "  1. Check prerequisites (Rust, dx CLI, etc.)"
    echo "  2. Create project structure"
    echo "  3. Generate all necessary files"
    echo "  4. Build the project"
    echo "  5. Create deployment package"
    echo ""
    echo "Project: $PROJECT_NAME"
    echo "Base path: $BASE_PATH (must match deployment folder name!)"
    echo ""
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborted"
        exit 0
    fi
    
    check_prerequisites
    create_project
    create_cargo_toml
    create_dioxus_toml
    create_main_rs
    create_readme
    create_gitignore
    create_deploy_script
    build_project
    create_deployment_package
    
    print_header "🎉 Setup Complete!"
    
    echo "Project created in: $(pwd)"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Test locally:"
    echo "   cd $PROJECT_NAME"
    echo "   dx serve"
    echo "   # Visit http://localhost:8080"
    echo ""
    echo "2. Deploy to shared hosting:"
    echo "   - Upload dioxus-deploy.zip to your host"
    echo "   - Extract in a folder named 'dioxus' (matching base_path)"
    echo "   - Access at: https://yourdomain.com/dioxus/"
    echo ""
    echo "3. Push to GitHub:"
    echo "   cd $PROJECT_NAME"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit: Dioxus test app'"
    echo "   git remote add origin https://github.com/yourusername/dioxus-test.git"
    echo "   git push -u origin main"
    echo ""
    print_success "All done!"
}

# Run main function
main
