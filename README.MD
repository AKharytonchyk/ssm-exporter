# AWS SSM Parameter Export and Import Scripts

These scripts allow you to export and import AWS SSM parameters to and from a JSON file. The export script retrieves SSM parameters and saves them into a JSON file, while the import script reads from this JSON file and re-creates the parameters in AWS SSM.

## Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured
- [jq](https://stedolan.github.io/jq/download/) installed for JSON processing
- Appropriate AWS IAM permissions to read and write SSM parameters

## Scripts

### 1. Export SSM Parameters to JSON

This script exports AWS SSM parameters to a JSON file.

#### Export Usage

```bash
./export_ssm_params_to_json.sh [-p | --pathTemplate <path>] [-h | --help]
```

#### Export Options

- `-p, --pathTemplate` : Specify the path template for SSM parameters. If not provided, all parameters will be pulled.
- `-h, --help` : Display the help message.

#### Export Example

```bash
./export_ssm_params_to_json.sh -p /my/custom/path
```

If no path template is provided, the script will pull all parameters.

### 2. Import SSM Parameters from JSON

This script imports AWS SSM parameters from a JSON file created by the export script.

#### Import Usage

```bash
./import_ssm_params_from_json.sh [-h | --help]
```

#### Import Options

- `-h, --help` : Display the help message.

#### Import Example

```bash
./import_ssm_params_from_json.sh
```

## Usage

1. **Configure AWS CLI**: Authenticate AWS CLI with first account.

   ```bash
   aws configure
   ```

1. **Export SSM Parameters**: Run the export script to save SSM parameters to `parameters.json`.

   ```bash
   ./export_ssm_params_to_json.sh -p /my/custom/path
   ```

1. **Configure AWS CLI**: Authenticate AWS CLI with first account.

   ```bash
   aws configure
   ```

1. **Import SSM Parameters**: Run the import script to read from `parameters.json` and recreate the parameters in AWS SSM.

   ```bash
   ./import_ssm_params_from_json.sh
   ```

## Notes

- Ensure that `jq` is installed and accessible in your PATH.
- Ensure that you have the necessary IAM permissions to read and write SSM parameters.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
