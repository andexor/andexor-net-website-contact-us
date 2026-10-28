<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins <ed@andexor.net>
-->

# Security Policy

Thank you for helping keep Andexor Network, Inc. and its ecosystem secure. This policy covers the source code in this
repository. For a security problem with the live website at https://andexor.net/, with an email address at
andexor.net, or with a service Andexor hosts, use the company's [Security Policy](https://andexor.net/security)
instead. It states the scope, the response times, the coordinated disclosure window, and the safe harbor for
good-faith research. Reports about the code are welcome through either channel.

## Reporting Security Issues

If you discover a security vulnerability in this repository, please report it through one of the following methods:

- Use the "Report a vulnerability" button on the Security Advisories page in the "Security" tab of the repository.
  This follows the [GitHub Security Advisory process](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability).
- Send an email to security@andexor.net.

Please **do not** report security vulnerabilities through public GitHub issues, discussions, or pull requests.

See the following documents for further details.

- [Coordinated disclosure of security vulnerabilities](https://docs.github.com/en/code-security/concepts/vulnerability-reporting-and-management/coordinated-disclosure)
- [Privately reporting a security vulnerability](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)
- [Vulnerability Disclosure Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerability_Disclosure_Cheat_Sheet.html)

## What to Include

To help us triage and respond quickly, please include:

- A description of the vulnerability and the file or component it is in
- Steps to reproduce the issue, with a request, a URL, or a snippet where that helps
- The potential impact
- Any suggested fixes (optional)

## Trust Model

This repository builds a static marketing website. Knowing what it does, and does not do, helps you tell a genuine
vulnerability from a design choice.

- The site is generated at build time by Next.js with static export. There is no server-side rendering, no API
  route, no database, and no user account. The only server-side code is `server.ts`, a small static file server
  that serves the built `out/` directory from a Docker container.
- The site stores no personal information. The Contact Us form has no backend yet; nothing it collects leaves the
  visitor's browser.
- Every page is public. There is nothing to authenticate to and no privileged role.
- The site runs in the visitor's browser with the privileges of any web page. Scripts come from this repository's
  build and from the pinned dependencies in `bun.lock`; the site loads no third-party scripts at run time.
- Content pages are Markdown files in `content/`, written by the site's owner and rendered at build time. Raw HTML in
  them is not rendered. They are trusted input, not user input.
- The build runs in Docker from the root `Dockerfile` and installs dependencies with a frozen lockfile.

## Behaviors That Are Not Vulnerabilities

The following are intentional and are **not** eligible for security vulnerability reports:

- Public availability of all page content, including the names of staff, the mailing address, the phone number, and
  the email addresses published on the site.
- The site's source code, dependency list, and build configuration being public in this repository.
- Directory structure, file names, or framework version information that can be read from the built site, such as
  the `_next/` path or the `site-*.js` chunk.
- Missing security headers, missing best practices, or configuration observations that do not lead to a demonstrated
  vulnerability.
- Findings from automated scanners without a demonstrated, specific impact.
- Self-XSS, clickjacking, and other issues that require a visitor to take an unlikely action against their own
  interests.
- Vulnerabilities in a third-party service we use or link to, such as GitHub, LinkedIn, X, or the hosting provider.
  Report those to the service's owner.
- Dependency advisories that do not affect this project's use of the dependency. A report is welcome if you can show
  how the vulnerable code is reached from the built site or the build.

## What Remains In Scope

The following categories **are** considered security vulnerabilities when they arise from flaws in this repository:

- **Content injection or cross-site scripting (XSS)**: any way for a page to run script or render markup that the
  Markdown source or the components did not intend
- **Path traversal or information disclosure in `server.ts`**: serving a file outside `out/`, or exposing the
  container's file system or environment
- **Supply chain**: a build script, dependency override, or Dockerfile step that could fetch or run code from an
  untrusted source, or that bypasses the frozen lockfile
- **Build-time code execution**: a Markdown file, front matter, or asset that causes the build to run code
- **Denial of service in `server.ts`** from a single malformed request, such as a crash or a hang, as distinct from
  volume-based attacks, which are out of scope
- **Secrets in the repository or the built site**: a credential, token, or private key committed by mistake

This list is not exhaustive.

## Vulnerability Disclosure

Security reports about this repository are handled through GitHub Security Advisories. Private vulnerability
reporting is enabled on this repository and should be enabled on every repository in the organization.

We acknowledge reports within 3 business days and aim to fix a confirmed issue within 90 days. Please give us that
time before you discuss the issue publicly. Research that follows this policy and the website's
[Security Policy](https://andexor.net/security) is covered by the safe harbor described there.

### Reporting Guidelines

When evaluating whether to report a potential security issue:

1. **Check this document first.** If the behavior is listed as intended, it is not a vulnerability.
2. **Consider the trust model.** If the issue requires control of the repository, the build, or the Markdown
   content, it is not a vulnerability in the site. It may still be worth an ordinary issue.
3. **Focus on unexpected access.** Vulnerabilities typically involve reading, running, or changing something that
   the trust model says should not be possible.
4. **Provide context.** If you believe you have found a genuine vulnerability, explain how it violates the intended
   security boundaries.
