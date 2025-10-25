# MetaNote Security Policy

## 🔒 Reporting Security Vulnerabilities

If you discover a security vulnerability in MetaNote, please report it responsibly:

### 📧 Contact
- **Email**: [security@metanote.app] (replace with actual email)
- **Subject**: "MetaNote Security Vulnerability Report"

### 📋 What to Include
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if available)

### ⏰ Response Timeline
- **Initial Response**: Within 24 hours
- **Vulnerability Assessment**: Within 72 hours
- **Fix Timeline**: Depends on severity (1-30 days)

## 🛡️ Security Measures

### API Key Protection
- Never commit API keys to version control
- Use environment variables or secure configuration files
- Regularly rotate API keys

### Data Security
- All user data is stored locally on device
- Optional encryption for sensitive data
- No personal data is sent to external services (except Google Gemini for text analysis)

### Network Security
- All API calls use HTTPS
- Certificate pinning recommended for production
- Request timeout and retry mechanisms

## 🔍 Security Checklist for Contributors

Before submitting a PR, ensure:
- [ ] No API keys or secrets in code
- [ ] No sensitive data in logs
- [ ] Proper input validation
- [ ] Error handling doesn't expose system information
- [ ] Dependencies are up to date

## 📚 Additional Resources
- [Google AI Responsible AI Practices](https://ai.google/responsibility/responsible-ai-practices/)
- [Flutter Security](https://docs.flutter.dev/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security-testing-guide/)

---
Last Updated: October 25, 2025