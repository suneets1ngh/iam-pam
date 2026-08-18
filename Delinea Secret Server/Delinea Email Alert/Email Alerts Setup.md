## For customization requests, enhancements, or implementation support, feel free to connect on LinkedIn: https://in.linkedin.com/in/suneet-singh-918491153
# Delinea Health Report Automation

PowerShell automation to allow effecient monitoring of the health, connectivity, deployment status, and version information of **Delinea Platform Connectors, Platform Engines, and Secret Server Distributed Engines**.

The script retrieves component information through the **Delinea Platform and Secret Server APIs**, generates a **colour-coded HTML health report**, and delivers it through **Microsoft Power Automate**.

## Features

* 🔐 Delinea Platform authentication
* 🔌 Delinea Platform Connector monitoring
* ⚙️ Delinea Platform Engine monitoring
* 🖥️ Secret Server Distributed Engine monitoring
* 🟢 Online / connected status detection
* 🔴 Offline / disconnected status detection
* 📦 Component version reporting
* ⬆️ Distributed Engine version comparison
* 📊 Colour-coded HTML health report
* 📧 Automated & secure email delivery using Power Automate
* ⚡ Designed to be executed as Scheduled Task with Windows Task Scheduler

## Architecture

<img width="1024" height="1536" alt="Delinea Email Alert" src="https://github.com/user-attachments/assets/b9c7a61e-795f-43fd-8d7e-77214642f073" />

## Requirements

* PowerShell
* A specific Delinea service/application account
* Delinea Platform & Secret Server API access
* Microsoft Power Automate

## Configuration

Update the environment-specific values in the script:

```powershell
$client_id     = "YOUR_CLIENT_ID"
$client_secret = "YOUR_CLIENT_SECRET"
$baseUrl       = "https://YOUR_TENANT.delinea.app"
```

Configure the Secret Server site IDs used for Distributed Engine discovery.

For Power Automate, configure an **HTTP-triggered flow** and replace the webhook URL in the script.

> ⚠️ **Security:** Never commit Delinea client secrets or your production Power Automate webhook URL to GitHub. Use a secure secret-management mechanism for production deployments.

## Power Automate

The script sends the generated HTML report as a JSON payload over HTTPS to Power Automate.

```text
PowerShell → HTTPS POST → Power Automate → Email
```

This avoids depending on legacy SMTP authentication from the PowerShell host.

## Report

The generated report provides a consolidated view of:

| Component           | Information                                       |
| ------------------- | ------------------------------------------------- |
| Platform Connectors | Name, machine, domain, status, version            |
| Platform Engines    | Name, machine, group, status, version             |
| Distributed Engines | Hostname, status, current version, latest version |

The HTML report uses visual status indicators to make unhealthy or outdated components immediately identifiable.

## Scheduling

The script can be executed automatically using **Windows Task Scheduler**.

## Technologies

**PowerShell · Delinea Platform · Delinea Secret Server · REST API · Microsoft Power Automate · Microsoft 365**

## Disclaimer

This project is intended for authorized Delinea administration and automation.

Delinea API endpoints and response structures may change between platform versions. Validate the script against your environment before using it in production.

## Keywords

`Delinea` `Secret Server` `Delinea Platform` `PAM` `Privileged Access Management` `PowerShell` `Power Automate` `REST API` `OAuth 2.0` `Distributed Engine` `Platform Engine` `Platform Connector` `Cybersecurity Automation` `PAM Automation`
