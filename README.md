📺 iPlayer Convert

A robust Bash script to automate post-processing of get_iplayer downloads. It:

    ✅ Converts .mp4 files to H.265 using ffmpeg

    ✅ Automatically renames files to SxxExx format for Jellyfin/Sonarr

    ✅ Detects and skips in-progress downloads

    ✅ Moves processed files to a blackhole directory (e.g. Sonarr)

    ✅ Works fully unattended (auto-detects show name, series, and episode from filename)

    ✅ Supports CLI overrides and config file


🚀 Features
Feature	Description
🔍 Auto-detect show/series	No config required — reads from file names like Show_Name_Series_25_-_07
🎬 H.265 Conversion	Reduces size with ffmpeg using CRF 24 and medium preset
🎯 Jellyfin/Sonarr Compatible	Renames output to Show Name S25E07.mp4
🧠 Smart File Handling	Skips files still downloading, prevents duplicates
⚙ Configurable	CLI overrides or ~/.iplayer_convert.conf for persistent settings
📁 Filename Example

Input:

Escape_to_the_Country_Series_25_-_07._Devon_m0023jdj_original.mp4

Auto-detected:

    Show: Escape to the Country

    Series: 25

    Episode: 07

Output:

Escape to the Country S25E07.mp4

🛠 Installation

Clone the repo and make the script executable:

git clone https://github.com/brownster/get-iplayer-post-processing.git
cd get-iplayer-post-processing
chmod +x get_iplayer_PP.sh

⚙ Configuration (Optional)

Create ~/.iplayer_convert.conf:

show_name="Escape to the Country"
series_number="25"
src_dir="$HOME/Downloads/get_iplayer-3.35"
dest_dir="$HOME/remote/downloads/transmission/sonarr"
enable_log=false

🚦 Usage
Basic (zero config):

./iplayer_convert.sh

With CLI overrides:

./iplayer_convert.sh \
  --series 26 \
  --show-name "Country House Rescue" \
  --src-dir "/path/to/downloads" \
  --dest-dir "/path/to/sonarr"

🔁 get_iplayer Post-Processing

To run this automatically after each download, add this to your ~/.get_iplayer/options:

command = /path/to/iplayer_convert.sh "<file>"

🧪 Testing

We use BATS for unit and integration tests.
Run tests locally:

bats test/

GitHub Actions CI:

See .github/workflows/test.yml for pipeline setup.
📄 License

MIT — see LICENSE.
💡 Contributing

PRs welcome! Please add test coverage for new logic and run shellcheck before committing.
