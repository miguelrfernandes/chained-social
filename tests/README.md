# Justfile Tests

This directory contains comprehensive unit tests for the Justfile used in the Chained Social ICP Project.

## Testing Framework

- **Framework**: pytest
- **Mocking**: unittest.mock (built-in Python)
- **Coverage**: Tests cover all Justfile targets and error conditions

## Test Structure

- `test_justfile.py`: Main test file with comprehensive test coverage
- `conftest.py`: Pytest configuration and fixtures
- `requirements-test.txt`: Testing dependencies

## Running Tests

```bash
# Install test dependencies
pip install -r tests/requirements-test.txt

# Run all tests
pytest tests/

# Run with verbose output
pytest tests/ -v

# Run specific test class
pytest tests/test_justfile.py::TestJustfileCommands -v

# Run with coverage (if pytest-cov is installed)
pytest tests/ --cov=. --cov-report=html
```

## Test Categories

1. **Command Tests**: Test individual Justfile targets (clean, deploy, test, etc.)
2. **URL Generation Tests**: Test canister URL formatting and validation
3. **Error Handling Tests**: Test failure scenarios and error recovery
4. **Validation Tests**: Test Justfile structure and content validation
5. **Integration Tests**: Test command sequences and workflows
6. **Canister Management Tests**: Test canister-specific functionality

## Key Testing Features

- Mocked subprocess calls to avoid actual command execution
- Temporary directory fixtures for safe file system testing
- Comprehensive error scenario testing
- URL format validation for IC canisters
- Integration testing for command workflows