# DevOps Capstone Project - Troubleshooting Guide

## Common Issues and Solutions

### TypeScript/React Issues

#### Issue: "Cannot find module 'react' or its corresponding type declarations"

**Problem:** The React dependencies haven't been installed yet.

**Solution:**
```bash
# Navigate to frontend directory
cd services/frontend

# Install dependencies
npm install

# If you get permission errors on Linux/Mac:
sudo npm install

# On Windows, run as Administrator if needed
```

**Alternative solution:**
```bash
# Use the setup script
chmod +x scripts/setup-frontend.sh
./scripts/setup-frontend.sh
```

#### Issue: "Cannot find name 'process'"

**Problem:** TypeScript doesn't recognize Node.js environment variables in React.

**Solution:** This is already fixed with the `react-app-env.d.ts` file. If still having issues:
```bash
# Make sure @types/node is installed
npm install --save-dev @types/node

# Or reinstall all dependencies
rm -rf node_modules package-lock.json
npm install
```

#### Issue: JSX element implicitly has type 'any'

**Problem:** React types are not properly loaded.

**Solution:**
```bash
# Ensure React types are installed
npm install --save-dev @types/react @types/react-dom

# Restart TypeScript server in VS Code
# Ctrl+Shift+P -> "TypeScript: Restart TS Server"
```

### Build Issues

#### Issue: Docker build fails with "npm install" errors

**Problem:** Dependencies not properly installed before Docker build.

**Solution:**
```bash
# Install dependencies first
cd services/frontend
npm install
cd ../backend  
npm install
cd ../..

# Then build Docker images
eval $(minikube docker-env)
docker build -t capstone/frontend:latest services/frontend/
docker build -t capstone/backend:latest services/backend/
```

#### Issue: "EACCES: permission denied" during npm install

**Solution:**
```bash
# On Linux/Mac - fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile
source ~/.profile

# Or use sudo (not recommended for development)
sudo npm install

# On Windows - run as Administrator
```

### Kubernetes/Minikube Issues

#### Issue: Minikube won't start

**Solution:**
```bash
# Delete and recreate Minikube
minikube delete
minikube start --driver=docker --cpus=4 --memory=6144

# If Docker driver fails, try VirtualBox
minikube start --driver=virtualbox --cpus=4 --memory=6144
```

#### Issue: Images not found in Minikube

**Solution:**
```bash
# Make sure to use Minikube's Docker daemon
eval $(minikube docker-env)

# Verify you're using the right Docker context
docker context ls

# Rebuild images in Minikube context
docker build -t capstone/frontend:latest services/frontend/
docker build -t capstone/backend:latest services/backend/

# Verify images are available
docker images | grep capstone
```

#### Issue: Pods stuck in "ImagePullBackOff"

**Solution:**
```bash
# Check if images exist in Minikube
eval $(minikube docker-env)
docker images

# If not, rebuild them
docker build -t capstone/frontend:latest services/frontend/
docker build -t capstone/backend:latest services/backend/

# Restart the deployment
kubectl rollout restart deployment/frontend -n capstone
kubectl rollout restart deployment/backend -n capstone
```

### Development Environment Setup

#### Complete Setup from Scratch

```bash
# 1. Install Node.js (if not installed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be 18.x
npm --version   # Should be 8.x or higher

# 2. Setup frontend
cd services/frontend
npm install

# Test frontend
npm start  # Should start on http://localhost:3000

# 3. Setup backend  
cd ../backend
npm install
mkdir -p logs

# Test backend
npm start  # Should start on http://localhost:3000

# 4. Continue with Kubernetes deployment
cd ../..
./scripts/deploy-all.sh
```

### Dependencies Installation Issues

#### Issue: npm install fails with network errors

**Solution:**
```bash
# Clear npm cache
npm cache clean --force

# Use different registry
npm config set registry https://registry.npmjs.org/

# Install with verbose logging
npm install --verbose

# If behind corporate firewall
npm config set proxy http://proxy.company.com:port
npm config set https-proxy http://proxy.company.com:port
```

#### Issue: Package vulnerabilities detected

**Solution:**
```bash
# Audit and fix vulnerabilities
npm audit
npm audit fix

# If fixes break dependencies
npm audit fix --force

# Or update specific packages
npm update axios
npm update react react-dom
```

### VS Code TypeScript Issues

#### Issue: VS Code shows TypeScript errors but code works

**Solutions:**
```bash
# 1. Restart TypeScript server
# Ctrl+Shift+P -> "TypeScript: Restart TS Server"

# 2. Clear VS Code workspace cache
# Ctrl+Shift+P -> "Developer: Reload Window"

# 3. Check TypeScript version
npx tsc --version

# 4. Ensure proper tsconfig.json
# File should be in services/frontend/tsconfig.json
```

### Testing Issues

#### Issue: Tests fail with module not found errors

**Solution:**
```bash
cd services/frontend

# Install test dependencies
npm install --save-dev @testing-library/jest-dom @testing-library/react @testing-library/user-event

# Run tests
npm test

# Run tests with coverage
npm run test:ci
```

### Quick Fixes Checklist

When encountering issues, try these in order:

1. **Check Node.js version:**
   ```bash
   node --version  # Should be 16+ 
   npm --version   # Should be 8+
   ```

2. **Install dependencies:**
   ```bash
   cd services/frontend && npm install
   cd ../backend && npm install
   ```

3. **Clear caches:**
   ```bash
   npm cache clean --force
   rm -rf services/*/node_modules services/*/package-lock.json
   ```

4. **Restart development servers:**
   ```bash
   # Kill any running processes
   pkill -f "node"
   pkill -f "npm"
   ```

5. **Check Minikube status:**
   ```bash
   minikube status
   kubectl cluster-info
   ```

6. **Verify Docker context:**
   ```bash
   eval $(minikube docker-env)
   docker context ls
   ```

### Environment Verification Script

Create and run this script to verify your environment:

```bash
#!/bin/bash
echo "=== Environment Check ==="
echo "Node.js: $(node --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "npm: $(npm --version 2>/dev/null || echo 'NOT INSTALLED')" 
echo "Docker: $(docker --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'NOT INSTALLED')"
echo "Minikube: $(minikube version --short 2>/dev/null || echo 'NOT INSTALLED')"
echo "Helm: $(helm version --short 2>/dev/null || echo 'NOT INSTALLED')"

echo -e "\n=== Minikube Status ==="
minikube status 2>/dev/null || echo "Minikube not running"

echo -e "\n=== Dependencies Check ==="
[ -d "services/frontend/node_modules" ] && echo "Frontend deps: ✓" || echo "Frontend deps: ✗"
[ -d "services/backend/node_modules" ] && echo "Backend deps: ✓" || echo "Backend deps: ✗"
```

### Getting Help

If you're still having issues:

1. **Check the specific error message** - most errors are self-explanatory
2. **Run the health check script:** `./scripts/health-check.sh`
3. **Check logs:** `kubectl logs -f deployment/frontend -n capstone`
4. **Verify each step** in the implementation guide
5. **Use the cleanup script** and start fresh: `./scripts/cleanup.sh`

### Contact Information

For additional support:
- Check project documentation: `README.md`, `IMPLEMENTATION.md`
- Review error logs carefully
- Use VS Code's integrated terminal for better error visibility
- Enable verbose logging: `npm install --verbose`