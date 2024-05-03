import os
import json
import subprocess
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_config():
    """Load and validate JSON configuration file."""
    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rna_seq_config.json')
    with open(file_path, 'r') as file:
        config = json.load(file)
    validate_config(config)
    return config

def validate_config(config):
    """Validate the necessary configuration fields are present."""
    required_keys = ['name', 'paths', 'path_order']
    for script in config['scripts']:
        if not all(key in script for key in required_keys):
            raise ValueError(f"Missing required configuration keys in script: {script.get('name', 'Unknown')}")
        if not all(key in script['paths'] for key in script['path_order']):
            raise ValueError(f"Missing required path keys in script: {script['name']} based on defined path_order.")

def run_script(script_config, extra_args=None):
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), script_config['name'])
    path_order = script_config.get('path_order', sorted(script_config['paths'].keys()))
    args = [script_config['paths'][key] for key in path_order]

    logging.info(f"Running script: {script_path} with arguments: {args}")

    if extra_args:
        args.extend(extra_args)

    command = ['bash', script_path] + args
    try:
        subprocess.run(command, check=True)
        logging.info(f"Successfully executed {script_path}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to execute {script_path}: Return code {e.returncode}")
    except Exception as e:
        logging.error(f"An unexpected error occurred while executing {script_path}: {e}")

def display_menu(scripts):
    """Display the script selection menu."""
    print("\nPlease choose a script to run:")
    for idx, script in enumerate(scripts, start=1):
        print(f"{idx}. {script['name']} - {script['description']}")
    print(f"{len(scripts) + 1}. Exit")

def get_user_choice(scripts):
    """Get the user's script choice from the menu, ensuring valid input."""
    while True:
        try:
            choice = int(input("Enter your choice (number): "))
            if 1 <= choice <= len(scripts) + 1:
                return choice
            else:
                logging.warning("Invalid choice, please choose a number between 1 and %d", len(scripts) + 1)
        except ValueError:
            logging.warning("Invalid input, please enter a number.")

def main():
    config = load_config()
    while True:
        display_menu(config['scripts'])
        choice = get_user_choice(config['scripts'])
        if choice == len(config['scripts']) + 1:
            logging.info("Exiting...")
            break
        chosen_script = config['scripts'][choice - 1]

        logging.info(f"Starting {chosen_script['name']}...")
        extra_args = []
        if chosen_script['name'] == "trim.sh":
            csv_path = input("Please enter the full path for the CSV file: ")
            extra_args.append(csv_path)

        run_script(chosen_script, extra_args)

        if input("Do you want to choose another process? (yes/no): ").strip().lower() != 'yes':
            logging.info("Exiting...")
            break

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
