from flask import Flask, request, send_file
from TTS.api import TTS

app = Flask(__name__)

# load model once (important for speed)
tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC")

@app.route("/speak", methods=["POST"])
def speak():
    text = request.json["text"]
    file_path = "output.wav"

    tts.tts_to_file(text=text, file_path=file_path)

    return send_file(file_path, mimetype="audio/wav")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)