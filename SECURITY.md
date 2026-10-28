<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins<ed@andexor.net>
-->

# Security Policy

Thank you for helping keep Andexor Network, Inc. and its ecosystem secure. This policy stipulates our procedures for identifying and reporting on potential security issues.

## Reporting Security Issues

If you discover a security vulnerability in this repository, please report it through one of the following methods:

- Use the "New draft security advisory" button on the Security Advisories page in the "Security and quality" tab of the repository.
- Send an email to ed@andexor.net.
- Use the [GitHub Security Advisory process](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) for this repository.

Please **do not** report security vulnerabilities through public GitHub issues, discussions, or pull requests.

See the following documents for further details.

- [Coordinated disclosure of security vulnerabilities](https://docs.github.com/en/code-security/concepts/vulnerability-reporting-and-management/coordinated-disclosure)
- [Privately reporting a security vulnerability](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)
- [Vulnerability Disclosure Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerability_Disclosure_Cheat_Sheet.html)


## What to Include

To help us triage and respond quickly, please include:

- A description of the vulnerability
- Steps to reproduce the issue
- The potential impact
- Any suggested fixes (optional)

## Intended Behaviors

This section documents behaviors that are intentional design choices and are **not** considered security vulnerabilities. Understanding these behaviors helps developers build accurate threat models, enables security researchers to focus on genuine vulnerabilities, and clarifies the trust boundaries within MCP for all implementers.

## Trust Model

This is TBD for each repository.

## Behaviors That Are Not Vulnerabilities

The following behaviors are intentional features and are **not** eligible for security vulnerability reports.

## What Remains In Scope

The following categories **are** considered security vulnerabilities when they arise from flaws in the code:

- **Authentication/authorization bypasses**: Ways to access resources or invoke tools without proper authorization
- **Implementation vulnerabilities**: Bugs (buffer overflows, injection flaws, etc.)
- **Sandbox escapes**: Breaking out of intended isolation boundaries
- **Session hijacking**: Unauthorized access to another user's session
- **Token theft or leakage**: Vulnerabilities that expose access tokens
- **Cross-tenant access**: Accessing resources belonging to other users in multi-tenant deployments

This list is not exhaustive.

## Vulnerability Disclosure

Security reports are handled through GitHub Security Advisories on the affected repository. Private vulnerability reporting should be enabled on every repository in the organization.

### Reporting Guidelines

When evaluating whether to report a potential security issue:

1. **Check this document first.** If the behavior is listed as intended, it is not a vulnerability.
2. **Consider the trust model.** If the issue requires the attacker to already have access that the trust model assumes they have, it may not be a vulnerability.
3. **Focus on unexpected access.** Vulnerabilities typically involve accessing resources or performing actions that should not be possible given the established trust boundaries.
4. **Provide context.** If you believe you have found a genuine vulnerability, explain how it violates the intended security boundaries.
