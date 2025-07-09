# Daily Greeting Script

A simple bash script that provides a personalized greeting along with system information and stock market data.

## Features

- **Personalized greeting** with current user and day of the week
- **System information** including bash version and disk space usage
- **Stock market data** via Polygon.io API integration

## Prerequisites

- Bash shell (version 4.0 or higher recommended)
- `curl` command (usually pre-installed on most systems)
- Polygon.io API key (free tier available)

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chitresh99/Deep-Infras
   cd your-repo-name
   ```

2. **Make the script executable:**
   ```bash
   chmod +x greeting_script.sh
   ```

3. **Set up your API key:**
   ```bash
   export POLYGON_API_KEY="your_api_key_here"
   ```
   
   Or add it to your `.bashrc` or `.zshrc` for persistence:
   ```bash
   echo 'export POLYGON_API_KEY="your_api_key_here"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Usage

Run the script directly:
```bash
./greeting_script.sh
```

Or run with bash:
```bash
bash greeting_script.sh
```

## Sample Output

```
Hello chitresh ! Today is Wednesday, which is the best day of the entire week
Your bash shell version is: 5.1.16(1)-release. Enjoy!
Here is your current disk space
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       20G   8.5G   11G  45% /
Well we do see that you are interested in stocks
Here is a price for few of them
[JSON response with stock dividend data]
```

## API Information

This script uses the [Polygon.io API](https://polygon.io/) to fetch stock dividend information. You'll need to:

1. Sign up for a free account at [polygon.io](https://polygon.io/)
2. Get your API key from the dashboard
3. Set it as an environment variable named `POLYGON_API_KEY`

## Customization

Feel free to modify the script to:
- Change the greeting message
- Add more system information
- Use different stock API endpoints
- Add error handling for API calls

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the [MIT License](LICENSE).