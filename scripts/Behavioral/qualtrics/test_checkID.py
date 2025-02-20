from flask import Flask, request, jsonify
import gspread
from oauth2client.service_account import ServiceAccountCredentials

# Flask app
app = Flask(__name__)

# Google Sheets setup
scope = [
    'https://www.googleapis.com/auth/spreadsheets',
    "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/drive"
]
file_json = r'X:\PROJECTS\ABC@UofSC\3-Experiments\NSF_valence\github\ABC_valence\scripts\Behavioral\qualtrics\abc-narrative-69c8408d0e56.json'
creds = ServiceAccountCredentials.from_json_keyfile_name(file_json, scope)
client = gspread.authorize(creds)
sheet = client.open('SONA_exp_test').sheet1

# Flask route to check embedded data
@app.route('/check_participant', methods=['GET'])
def check_participant():
    # Get participant ID from query parameters
    participant_id = request.args.get('id')
    
    if not participant_id:
        return jsonify({"error": "Missing participant ID"}), 400
    
    # Get all data from the Google Sheet
    records = sheet.get_all_records()
    ids = [str(row['ParticipantID']) for row in records]  # Replace 'ParticipantID' with your column name
    
    # Check if the participant ID exists in the sheet
    if participant_id in ids:
        return jsonify({"status": "Yes", "message": "The participant has finished"}), 200
    else:
        return jsonify({"status": "No", "message": "The participant has not finished"}), 200

if __name__ == '__main__':
    app.run(debug=True)
