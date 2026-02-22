# Delinea Secret Server Just-In-Time (JIT) Privileged Access Implementation Guide

## Overview

**JIT: Just In Time** is simply a way to provision time-bound privileges to an account only when needed/requested.

There is one way to achieve that in our current environment using only Secret Server, which will help us eliminate standing Administrator/privileged accounts.

---

## Check In/Out with Hooks

Using the Hooks functionality along with Check In & Check Out on a Secret, JIT can be implemented.

### Check In / Check Out
- Provides the user exclusive access to the Secret
- Access is granted for a limited amount of time

### Hooks
- Allows us to trigger/run predefined scripts on both Check In & Check Out actions
- Whenever Check-in/Check-out happens, a script will be executed automatically

---

## Flow of JIT via Check In/Out with Hooks

Two scripts are created (preferably PowerShell).

### Script A
- Triggers on **Check Out** action  
- Executes whenever a user checks out a secret  
- Adds the credentials on the secret to an AD admin group  

### Script B
- Triggers on **Check In** action  
- Executes whenever:
  - A user checks in a secret, OR  
  - The checkout duration expires  
- Removes the credentials on the secret from the AD admin group  

---

## Not JIT but Secure

There is one more way to make accounts more secure along with implementing time-bound access to that account.

This is not JIT but helps harden security.

### Remote Password Change (RPC) on Check In

- This can be achieved by enabling RPC on Check In  
- This is an already available feature  
- No customization is needed  

RPC ensures the password is rotated when the secret is checked back in, improving overall security posture.


---

## Customizations & Support

For customization requests, enhancements, or implementation support, feel free to connect:
LinkedIn: https://in.linkedin.com/in/suneet-singh-918491153
