# Contributing to MetaNote

🎉 Thank you for your interest in contributing to MetaNote!

## 🤝 How to Contribute

### 🐛 Bug Reports
1. Check existing issues first
2. Use the bug report template
3. Include steps to reproduce
4. Provide system information (Flutter version, OS, etc.)

### 💡 Feature Requests
1. Check if the feature already exists or is planned
2. Use the feature request template
3. Explain the use case and benefits
4. Consider backward compatibility

### 🔧 Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow our coding standards
4. Add tests for new functionality
5. Update documentation if needed
6. Commit with clear messages
7. Push to your branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📝 Coding Standards

### Dart/Flutter Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` and fix all warnings
- Format code with `dart format`
- Add documentation comments for public APIs

### Security Guidelines
- **NEVER** commit API keys or secrets
- Use environment variables for configuration
- Validate all user inputs
- Handle errors gracefully without exposing system details

### Commit Messages
Use conventional commits format:
```
type(scope): description

- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting
- refactor: code restructuring
- test: adding tests
- chore: maintenance
```

## 🧪 Testing
- Write tests for new features
- Ensure all tests pass: `flutter test`
- Test on multiple platforms if possible
- Include integration tests for critical paths

## 📚 Documentation
- Update README.md if needed
- Add inline code documentation
- Update API documentation
- Include examples for new features

## 🔒 Security
- Report security issues privately (see SECURITY.md)
- Never include sensitive data in commits
- Follow secure coding practices
- Review third-party dependencies

## ❓ Questions?
- 💬 GitHub Discussions for general questions
- 🐛 GitHub Issues for bugs
- 📧 Email for security concerns

## 📜 License
By contributing, you agree that your contributions will be licensed under the MIT License.

---
Happy coding! 🚀