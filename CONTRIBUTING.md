# Contributing to terraform-aws-multi-az-production

We welcome contributions! Please follow these guidelines:

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Guidelines

- Run `terraform fmt -recursive` before committing
- Run `terraform validate` to check syntax
- Update documentation for any new variables/outputs
- Add examples if introducing new features

## Testing

- Test changes in a sandbox AWS account
- Verify both creation and destruction of resources
- Check for any drift after applying

## Code Style

- Use descriptive variable names
- Add comments for complex logic
- Follow HashiCorp's Terraform style guide