// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';

// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
	
	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "dt-vscode-template" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	let build = vscode.commands.registerCommand('dt-vscode-template.build', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		vscode.window.showInformationMessage('Build solution...');
	});

	let run = vscode.commands.registerCommand('dt-vscode-template.run', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		vscode.window.showInformationMessage('Run solution...');
	});

	let stop = vscode.commands.registerCommand('dt-vscode-template.stop', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		vscode.window.showInformationMessage('Stop solution...');
	});

	let restart = vscode.commands.registerCommand('dt-vscode-template.restart', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		vscode.window.showInformationMessage('Restart bot interface...');
	});


	context.subscriptions.push(build);
	context.subscriptions.push(run);
	context.subscriptions.push(stop);
	context.subscriptions.push(restart);
}

// this method is called when your extension is deactivated
export function deactivate() {}
