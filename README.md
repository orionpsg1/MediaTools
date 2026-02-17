# MediaTools

MediaTools is a unified PowerShell media routing wrapper that orchestrates multiple third-party download tools through a single command interface.

---

## Features

- Unified `media` command router
- Tool-based routing (YouTube, Instagram, KHInsider, Coomer, etc.)
- Centralized download directory
- Structured tool subdirectories
- Logging support
- Configurable output path
- Portable architecture

---

## Supported Tools

MediaTools acts as a wrapper for the following external utilities:

| Tool        | Purpose | License |
|-------------|---------|---------|
| gallery-dl  | General media downloading | GPL-2.0 |
| CoomerDL    | Coomer.party downloader | GPL-3.0 |
| KHInsider script | Game soundtrack downloader | Varies |
| Python 3.x  | Required runtime | PSF License |
| Node.js     | Required for certain tools | MIT |

---

## Tested Versions

These are the versions verified during development:

- gallery-dl: 1.26.x
- CoomerDL: 2.x
- Python: 3.11+
- Node.js: 20.x LTS
- PowerShell: 5.1 / 7+

(Users are responsible for installing and maintaining these tools.)

---

## Installation

1. Clone this repository.
2. Place the module in your PowerShell module directory:
3. Import the module:


## Requirements

- Python 3.10+
- Node.js (recommended for yt-dlp JS runtime)
- ffmpeg (must be in PATH)

Install Python dependencies:

    pip install -r requirements.txt

---

## Dependency Cross Reference

Shared Across Tools:
- requests
- urllib3
- certifi

Used by Scrapers:
- beautifulsoup4
- lxml
- tqdm

Used by Media Processing:
- mutagen
- brotli

Used by gallery-dl:
- browser-cookie3

Used by CoomerDL forks:
- aiohttp
- aiofiles

System Dependencies:
- ffmpeg (yt-dlp)
- nodejs (yt-dlp JS runtime)


## Configuration

User configurations are stored and referenced in:

    ~.\Users\%userprofile%\Documents\WindowsPowerShell\Modules\MediaTools

---

## Usage

Download:

    media <url>

Update tools:

    media-update
	
Examples:

	media https://www.instagram.com/example/

	media https://youtube.com/watch?v=xxxx

	media battle-mania-trouble-shooter-genesis
---

## Download Folder Structure

Downloads are saved to: 

    M:\Downloads

Tool-specific subdirectories are automatically created:

	M:\Downloads\gallery
	M:\Downloads\coomer
	M:\Downloads\khinsider
---

## Logging

Logs can be configured via the module config file.

---

## License

MediaTools is licensed under the MIT License.

Third-party tools retain their own licenses.
See THIRD_PARTY_LICENSES.md for details.

---

## Disclaimer

MediaTools does not host or distribute copyrighted material.
Users are responsible for ensuring they comply with applicable laws and the terms of service of the sites they access.

