This PowerShell script is designed to enable and disable “Solo Mode” for Destiny 2 by creating and removing firewall rules, effectively preventing online matchmaking while the game is running. Here’s a breakdown of how the script works:

Features and Workflow:
	1.	Administrator Privileges Check:
	•	Ensures the script runs with elevated permissions (required for firewall rule modifications).
	•	If not run as an administrator, it restarts itself with elevated permissions.
	2.	BurntToast Module:
	•	Sends notifications to the Windows Action Center to notify the user about the status of Solo Mode.
	•	Automatically installs the module if it’s not already available.
	3.	Notification Functionality:
	•	The Send-Notification function generates custom notifications to provide user feedback.
	4.	Firewall Rules for Solo Mode:
	•	Enable-SoloMode: Blocks inbound and outbound TCP/UDP traffic on the ports Destiny 2 uses for matchmaking (27000-27200 and 3097).
	•	Disable-SoloMode: Removes these firewall rules to restore network connectivity.
	5.	Process Monitoring:
	•	Continuously checks for the Destiny 2 process.
	•	Activates Solo Mode when the game starts.
	•	Deactivates Solo Mode when the game closes.
