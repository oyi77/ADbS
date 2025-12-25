import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

let myStatusBarItem: vscode.StatusBarItem;

export function activate(context: vscode.ExtensionContext) {
    console.log('ADbS extension is active!');

    // Command: Start Workflow
    let startDisposable = vscode.commands.registerCommand('adbs.start', async () => {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders) {
            vscode.window.showErrorMessage('No workspace open. Please open a folder.');
            return;
        }

        const rootPath = workspaceFolders[0].uri.fsPath;

        // Check if initialized
        const adbsConfig = path.join(rootPath, '.workflow-enforcer');
        if (!fs.existsSync(adbsConfig)) {
            const selection = await vscode.window.showWarningMessage(
                'ADbS not initialized. Initialize now?', 'Yes', 'No'
            );
            if (selection === 'Yes') {
                runAdbsCommand('init', rootPath);
            }
            return;
        }

        // Ask for stage
        const stage = await vscode.window.showQuickPick(
            ['explore', 'plan', 'requirements', 'design', 'tasks', 'execution'],
            { placeHolder: 'Select ADbS Stage to Activate' }
        );

        if (stage) {
            runAdbsCommand(`set-stage ${stage}`, rootPath);
        }
    });

    // Command: Next Stage
    let nextDisposable = vscode.commands.registerCommand('adbs.next', () => {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders) {
            runAdbsCommand('next', workspaceFolders[0].uri.fsPath);
        }
    });

    // Status Bar
    myStatusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    myStatusBarItem.command = 'adbs.start';
    context.subscriptions.push(myStatusBarItem);
    context.subscriptions.push(startDisposable);
    context.subscriptions.push(nextDisposable);

    const rootPath = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (rootPath) {
        const watcher = vscode.workspace.createFileSystemWatcher(
            new vscode.RelativePattern(rootPath, '.workflow-enforcer/current-stage')
        );
        watcher.onDidChange(() => updateStatusBarItem(rootPath));
        watcher.onDidCreate(() => updateStatusBarItem(rootPath));
        watcher.onDidDelete(() => updateStatusBarItem(rootPath));
        context.subscriptions.push(watcher);

        updateStatusBarItem(rootPath);
    } else {
        updateStatusBarItem();
    }
}

function runAdbsCommand(args: string, cwd: string) {
    // Assuming 'adbs' is in PATH or using local bin
    // For development, we might point to the local bin script
    const cmd = `bash lib/validator/workflow.sh ${args}`; // Fallback/Dev mode

    vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: "Running ADbS Command...",
        cancellable: false
    }, (progress) => {
        return new Promise<void>((resolve, reject) => {
            cp.exec(cmd, { cwd: cwd }, (err, stdout, stderr) => {
                if (err) {
                    vscode.window.showErrorMessage(`Error: ${stderr}`);
                    reject(err);
                } else {
                    vscode.window.showInformationMessage(`Output: ${stdout}`);
                    updateStatusBarItem(cwd);
                    resolve();
                }
            });
        });
    });
}

function updateStatusBarItem(cwd?: string) {
    if (!cwd) {
        cwd = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    }

    if (cwd) {
        const stageFile = path.join(cwd, '.workflow-enforcer', 'current-stage');
        if (fs.existsSync(stageFile)) {
            try {
                const stage = fs.readFileSync(stageFile, 'utf8').trim();
                myStatusBarItem.text = `$(rocket) ADbS: ${stage}`;
                myStatusBarItem.show();
                return;
            } catch (error) {
                console.error('Error reading stage file:', error);
            }
        }
    }
    myStatusBarItem.text = `$(circle-slash) ADbS`;
    myStatusBarItem.show();
}

export function deactivate() { }
