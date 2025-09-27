from flask import Flask, request, jsonify
from agent.agent import get_project_info, calculate_shade_percentage
from google.cloud import vision

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return "Welcome to the Shadesmith Agent!"

@app.route("/project-info", methods=["GET"])
def project_info():
    return jsonify(get_project_info())

@app.route("/shade-percentage", methods=["POST"])
def shade_percentage():
    data = request.json
    print(f"Received data: {data}")  # Debug log
    light_value = data.get("light_value", 0)
    max_light = data.get("max_light", 100.0)
    return jsonify(calculate_shade_percentage(light_value, max_light))

@app.route('/test-vision', methods=['GET'])
def test_vision():
    try:
        client = vision.ImageAnnotatorClient()

        with open("test-image.png", "rb") as image_file:
            content = image_file.read()

        image = vision.Image(content=content)
        response = client.label_detection(image=image)

        labels = [label.description for label in response.label_annotations]
        return jsonify(labels)
    except Exception as e:
        print(f"Error: {e}")  # Log the error
        return jsonify({"error": str(e)}), 500



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)