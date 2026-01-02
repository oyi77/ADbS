#!/usr/bin/env node

/**
 * ADbS npm postinstall script
 * Sets up ADbS in the user's project directory
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colors for console output
const colors = {
    blue: '\x1b[34m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    reset: '\x1b[0m'
};

function log(message, color = 'blue') {
    console.log(`${colors[color]}[ADbS]${colors.reset} ${message}`);
}

function success(message) {
    log(message, 'green');
}

function warning(message) {
    log(message, 'yellow');
}

// Check if we're in a global install
const isGlobalInstall = process.env.npm_config_global === 'true';

if (isGlobalInstall) {
    console.log('');
    success('ADbS installed globally!');
    console.log('');
    log('To use ADbS in your project:');
    console.log('  1. Navigate to your project directory');
    console.log('  2. Run: adbs setup');
    console.log('  3. Start working: adbs new <name>');
    console.log('');
    log('For help: adbs --help');
    console.log('');
} else {
    // Local install - set up .adbs directory
    const projectRoot = process.cwd();
    const adbsDir = path.join(projectRoot, '.adbs');

    console.log('');
    log('Setting up ADbS in your project...');

    try {
        // Create .adbs directory structure
        const dirs = [
            '.adbs/bin',
            '.adbs/lib',
            '.adbs/config',
            '.adbs/work',
            '.adbs/archive',
            '.adbs/internal'
        ];

        dirs.forEach(dir => {
            const fullPath = path.join(projectRoot, dir);
            if (!fs.existsSync(fullPath)) {
                fs.mkdirSync(fullPath, { recursive: true });
            }
        });

        // Copy files from node_modules to .adbs
        const nodeModulesPath = path.join(projectRoot, 'node_modules', '@adbs', 'cli');

        if (fs.existsSync(nodeModulesPath)) {
            // Copy bin
            const binSrc = path.join(nodeModulesPath, 'bin');
            const binDest = path.join(adbsDir, 'bin');
            if (fs.existsSync(binSrc)) {
                copyRecursive(binSrc, binDest);
            }

            // Copy lib
            const libSrc = path.join(nodeModulesPath, 'lib');
            const libDest = path.join(adbsDir, 'lib');
            if (fs.existsSync(libSrc)) {
                copyRecursive(libSrc, libDest);
            }

            // Copy config
            const configSrc = path.join(nodeModulesPath, 'config');
            const configDest = path.join(adbsDir, 'config');
            if (fs.existsSync(configSrc)) {
                copyRecursive(configSrc, configDest);
            }
        }

        success('ADbS directory structure created!');
        console.log('');
        log('Next steps:');
        console.log('  1. Run: npx adbs setup');
        console.log('  2. Start working: npx adbs new <name>');
        console.log('');
        log('Or add to package.json scripts:');
        console.log('  "scripts": {');
        console.log('    "adbs": "adbs"');
        console.log('  }');
        console.log('');

    } catch (error) {
        warning(`Setup incomplete: ${error.message}`);
        console.log('You can manually run: npx adbs setup');
    }
}

// Helper function to copy directory recursively
function copyRecursive(src, dest) {
    if (!fs.existsSync(dest)) {
        fs.mkdirSync(dest, { recursive: true });
    }

    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
        const srcPath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);

        if (entry.isDirectory()) {
            copyRecursive(srcPath, destPath);
        } else {
            fs.copyFileSync(srcPath, destPath);
            // Make scripts executable on Unix
            if (process.platform !== 'win32' && (entry.name.endsWith('.sh') || !entry.name.includes('.'))) {
                try {
                    fs.chmodSync(destPath, 0o755);
                } catch (e) {
                    // Ignore chmod errors
                }
            }
        }
    }
}
